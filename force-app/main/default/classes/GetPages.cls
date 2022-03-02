public with sharing class GetPages {
    // Variable Declarations
    
    public String retId {get;set;}   //  the id of the facebook User object and is used for redirection
    public String Imessage {get;set;}  // error messages to be shown on the page 
    public String printData {get;set;}  //used to store the JSON response and display on Page [for debugging purpose]
    public Facebook_User__c fbUserRef{get;set;} 
    public String accessToken{get;set;}  //stores the access token retrieved from user Object
    public List<Facebook_Pages__c> fbPageList;
    public Set<String> fbPageIds;  //set containing all the PageIds from Page Object
    public List<Facebook_Pages__c> fbPageObjectInsertList;
    public Facebook_Pages__c PageObj;   
    
    // End Of Variable Declaration
    
    //constructor
    public GetPages (){      
        retId = ApexPages.currentPage().getParameters().get('id');
        fbUserRef = [select Id,Access_Token__c,User_ID__c from Facebook_User__c where Id =: retId]; // retrieve the access token from the object based on SFDC User Id
        fbPageList = [select Id,Wall_Album_Id__c,Facebook_ID__c from Facebook_Pages__c where Facebook_User__c =: retId];  //retrieves all Page Id present In object per facebook user
        accessToken = fbUserRef.Access_Token__c;       
    }
    
    
    // This method is used to retrieve Pages that a particular user has created and stores them in facebook Page Object...
     
    public PageReference getPageData(){ 
        
        /****** Portion that gets the pages created by users. Single user may be associated with multiple pages. (Category = Application) are rejected*/
        
        String accountURL = 'https://graph.facebook.com/me/accounts?fields=description,category,likes,access_token,name,id&access_token='+accessToken ;    // request to FB Graph API to retrieve account information. The response is a JSON that contains the pages that the particular user has created.
        Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setEndpoint(accountURL);
        hreq.setMethod('GET');
        HttpResponse hres = h.send(hreq);
        String resp = hres.getBody();
        System.debug('resp : '+resp);
        //printData = resp; // printData variable is just used for printing the value on the GetPages Page Page.[Just for debugging purpose]
        
        Map<String,Facebook_Pages__c> pageObjMap = new Map<String,Facebook_Pages__c>();
        
        Map<String, Object> pageDataMap = (Map<String, Object>)JSON.deserializeUntyped(resp); // deserializing the JSON Response from facebook. 
        List<Object> pageDataList = (List<Object>)pageDataMap.get('data'); //retrieves all information from pageDataMap with Key - "data"           
        
        System.debug('pageDataList : '+pageDataList);
        
        Map<String, Object> tempPageDataMap = new Map<String, Object>();
        fbPageIds = new Set<String>();
        fbPageObjectInsertList = new List<Facebook_Pages__c>(); // used to insert Page Object..        
        
        if(fbPageList.size() > 0){  // contains all the pageIds from Page Object.
            for(Facebook_Pages__c p : fbPageList){
                fbPageIds.add(p.Facebook_ID__c);
                pageObjMap.put(p.Facebook_ID__c,p);
            }
        }

        if(pageDataList.size() > 0){
            for(Integer i=0;i<pageDataList.size();i++){
                tempPageDataMap = (Map<String, Object>)pageDataList[i];         
                system.debug(tempPageDataMap.keySet()+'  ........... tempPageDataMap  >>>>>>>>>>>>>  '+tempPageDataMap);
                if(tempPageDataMap.get('category') != 'Application'){  //will execute only when category is other that Application
                    if(((fbPageIds.contains(tempPageDataMap.get('id')+'')==false) && (fbPageList.size() > 0)) ||(fbPageList.size() == 0)){
                            PageObj = new Facebook_Pages__c();  //creating the PageObject
                            PageObj.Category__c = String.valueOf(tempPageDataMap.get('category'));  //inputting category field
                            PageObj.Facebook_ID__c = String.valueOf(tempPageDataMap.get('id'));  // inputting fb Id field
                            PageObj.Name = String.valueOf(tempPageDataMap.get('name'));  // inputting FB Page Name
                            PageObj.Facebook_User__c = retId;  // inputting FB user Id
                            PageObj.Access_Token__c = String.valueOf(tempPageDataMap.get('access_token'));
                            if(tempPageDataMap.containsKey('description')){
                                system.debug('Description >>>>>>>>>>>>>> '+tempPageDataMap.get('description'));
                                PageObj.Description__c = tempPageDataMap.get('description')+'';
                            }                     
                            PageObj.Last_Feed__c = system.now();
                            if(tempPageDataMap.containsKey('likes')){                               
                                PageObj.Likes__c = (Decimal)tempPageDataMap.get('likes');
                            }
                            PageObj.Likes__c = (Decimal)tempPageDataMap.get('likes');
                            fbPageObjectInsertList.add(PageObj);
                            fbPageIds.add(String.valueOf(tempPageDataMap.get('id')));  //updating the List of PageIds                         
                    }
                }
            }
        }
        
        if(fbPageObjectInsertList.size() > 0){
            for(Facebook_Pages__c p : fbPageObjectInsertList){
                String albumURL = 'https://graph.facebook.com/'+p.Facebook_ID__c+'/albums?access_token='+accessToken ;    // request to FB Graph API to retrieve album information.
                Http h1 = new Http();
                HttpRequest hreq1 = new HttpRequest();
                hreq1.setEndpoint(albumURL);
                hreq1.setMethod('GET');
                HttpResponse hres1 = h1.send(hreq1);
                String resp1 = hres1.getBody();
                //printData = resp1;
          
                system.debug('resp1 >>>>>>>>>>>>>>>>>>>>>>>>>  '+resp1);
                Map<String, Object> albumDataMap = (Map<String, Object>)JSON.deserializeUntyped(resp1); // deserializing the JSON Response from facebook. 
                List<Object> albumDataList = (List<Object>)albumDataMap.get('data'); //retrieves all information from pageDataMap with Key - "data"   
                system.debug(albumDataList.size()+'  ............ albumDataList  >>>>>>>>>>>> '+albumDataList);
                if(albumDataList.size() > 0){
                    for(Integer i = 0; i < albumDataList.size(); i++){
                        Map<String,Object> albumMap = (Map<String,Object>)albumDataList[i];
                        system.debug(albumMap.keySet()+'  .......... albumMap  >>>>>>>>>>>>>  '+albumMap);
                        if(albumMap.containsKey('type')){
                            String albumType = albumMap.get('type')+'';
                            system.debug('albumType >>>>>>>>>>>>>>>>>>>> '+albumType);
                            if(albumType == 'wall'){                                    
                                p.Wall_Album_Id__c = albumMap.get('id')+'';
                            }
                        }
                    }
                }
            }
        }
       
        insert fbPageObjectInsertList; // inserting the Page Object
        
        if(printData != null || Imessage != null){  // if error or printData has values, then print error/value and remain on GetPages Page
            return null;
        }else{
            PageReference pr = new PageReference('/' +retId);
            pr.setRedirect(true);
            return pr;
        }
    } //end method
}// end class
/*
Company : Fujitsu America
Date : 
Author : 
Description:
        1.This class is used to create a connection of user with facebook .
        2.This class generates access token using Appid and Appsecret which are manually provided by user .
        3.The class uses FQL(Facebook Query Language) to fetch users data ;data thus obtained is in form of JSON,
          so JSON deserialiser is used to deaerialise data and save to respective fields of Facebook user.  
*/ 



public class FacebookAuthenticateUser{   
    public String accessToken{get;set;}
    public String Imessage {get;set;} 
    public String facebookUserId{get;set;} 
    public Facebook_User__c fbUserObj;
    
    public FacebookAuthenticateUser(){
        FB_User__c fbuser = FB_User__c.getInstance();       
        facebookUserId = fbuser.FB_Id__c;
        
        fbUserObj = [select Wall_Album_Id__c,Name,User_ID__c,Email__c,Application_ID__c,Validate__c,Application_Secret__c,
                        Redirect_URI__c,Access_Token__c,Auth_Code__c from Facebook_User__c where Id =: facebookUserId];
    }
    
    public PageReference completeAuthorization() {

                        
        String authCode = Apexpages.currentPage().getParameters().get('code');
        if(authCode != null){           
            fbUserObj.Auth_Code__c = authCode;
            System.debug('authCode : '+authCode);               
            return getAccessToken();            
        }
        
        return null;
    }
    
    /*Method to Generate Access_Token*/
    public PageReference getAccessToken(){   
        
        system.debug('fbUserObj.Application_ID__c : '+fbUserObj.Application_ID__c+' fbUserObj.Application_Secret__c : '+fbUserObj.Application_Secret__c
                        +' fbUserObj.Redirect_URI__c : '+fbUserObj.Redirect_URI__c+' fbUserObj.Access_Token__c : '+fbUserObj.Access_Token__c);
               
        if(fbUserObj != null){          
            if((fbUserObj.Application_ID__c != null) && (fbUserObj.Application_Secret__c != null) && (fbUserObj.Redirect_URI__c != null) && (fbUserObj.Auth_Code__c != null)){
                    if(fbUserObj.Access_Token__c == null){
                        //retrieves the access token that will be needed to retrieve user specific informations from facebook....
                        // this url will return a response that contains the access token
                        String accessURL = 'https://graph.facebook.com/oauth/access_token?client_id='
                                            +fbUserObj.Application_ID__c+'&redirect_uri='+fbUserObj.Redirect_URI__c
                                            +'&client_secret='+fbUserObj.Application_Secret__c+'&code='+fbUserObj.Auth_Code__c;                        
                        Http h = new Http();
                        HttpRequest hreq = new HttpRequest();
                        hreq.setEndpoint(accessURL);
                        hreq.setMethod('GET');
                        HttpResponse hres = h.send(hreq);
                        String resp = hres.getBody();
                        System.debug('resp : '+resp);                        
         
                        if(resp != null && resp.trim()!='' && resp.indexOf('&') > -1){ //used to split the response and obtain the access token
                            accessToken = resp.substring(13, resp.indexOf('&'));      
                        }else if(resp != null && resp.trim()!=''){
                            accessToken = resp.substring(13,resp.length());
                        } 
                        
                        fbUserObj.Access_Token__c = accessToken;
                        fbUserObj.Validate__c=true;
                        
                        if(resp!=null && resp.trim()!='' && fbUserObj.Access_Token__c != null && fbUserObj.Access_Token__c.trim() != ''){
                            retrieveUserInfo(fbUserObj.Access_Token__c);
                        }                        
                    }else{                                       
                        retrieveUserInfo(fbUserObj.Access_Token__c);                        
                    }
                    update fbUserObj;
            }else{                                
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Application ID, Application Secret and Redirect URI are mandatory.'));
                return null;
            }
        }    
             
        PageReference pr = new PageReference('/' +facebookUserId);
        pr.setRedirect(true);
        return pr;                
    }
    
    private void retrieveUserInfo(String accessToken){
        //retrieves user information from facebook Graph API..
        Http httpInstance = new Http();
        
        String userURL = 'https://graph.facebook.com/me?access_token='+accessToken;       
        
        HttpRequest httpReqUserInfo = new HttpRequest();
        httpReqUserInfo.setEndpoint(userURL);
        httpReqUserInfo.setMethod('GET');
        HttpResponse httpRespUserInfo = httpInstance.send(httpReqUserInfo);
        String respBodyUserInfo = httpRespUserInfo.getBody();       
        userDetails u = (userDetails)Json.deserialize(respBodyUserInfo,FacebookAuthenticateUser.userDetails.class);
        fbUserObj.User_ID__c = u.id;
        fbUserObj.Name = u.userName ;
        fbUserObj.Name__c = u.name;
        fbUserObj.Email__c = u.email;       
        system.debug('u.id : '+u.id);        
        
        // http request to fill the album Id of type "wall" from the user's facebook account
        // Either of the following way works similarly. 
        //String albumURL = 'https://graph.facebook.com/'+u.id+'/albums?access_token='+accessToken ;    
        
        String albumURL = 'https://graph.facebook.com/me/albums?fields=id,type&access_token='+accessToken ;    // request to FB Graph API to retrieve album information.
        
        HttpRequest httpReqAlbumInfo = new HttpRequest();
        httpReqAlbumInfo.setEndpoint(albumURL);
        httpReqAlbumInfo.setMethod('GET');
        HttpResponse httpRespAlbumInfo = httpInstance.send(httpReqAlbumInfo);
        String respBodyAlbumInfo = httpRespAlbumInfo.getBody();     
        system.debug('respBodyAlbumInfo : '+respBodyAlbumInfo);
        
        Map<String, Object> albumDataMap = (Map<String, Object>)JSON.deserializeUntyped(respBodyAlbumInfo); // deserializing the JSON Response from facebook. 
        List<Object> albumDataList = (List<Object>)albumDataMap.get('data'); //retrieves all information from pageDataMap with Key - "data"   
        system.debug('albumDataList.size() : '+albumDataList.size()+' >>>>>>>> albumDataList : '+albumDataList);
        
        if(albumDataList.size() > 0){
            for(Integer i = 0; i < albumDataList.size(); i++){
                Map<String,Object> albumMap = (Map<String,Object>)albumDataList[i];
                system.debug('albumMap.keySet() : '+albumMap.keySet()+' >>>>>>>> albumMap : '+albumMap);
                if(albumMap.containsKey('type')){
                    String albumType = albumMap.get('type')+'';
                    system.debug('albumType : '+albumType);
                    if(albumType == 'wall'){                                    
                        fbUserObj.Wall_Album_Id__c = albumMap.get('id')+'';
                    }
                }
            }
        }
    }
    
    public class userDetails{
        public String userName{get;set;}
        public String id{get;set;}
        public String name{get;set;}
        public String email{get;set;}
        
        public userDetails(string userNameTest, String idTest,String name,String email){
            this.userName = userNameTest;
            this.id = idTest;
            this.name = name;
            this.email = email;
        }
    }
    
    public Pagereference backToFacebookUser(){
        Pagereference pageref = new Pagereference('/'+facebookUserId);
        return pageref;
    }
    
}
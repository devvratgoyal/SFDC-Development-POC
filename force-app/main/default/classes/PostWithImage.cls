public with sharing class PostWithImage {

    public String retId{get;set;} 
    public PageReference pr;
    public Facebook_Feeds__c feedObjRef{get;set;}
    public Facebook_Pages__c pageObjRef;
    public Facebook_User__c userObjRef;
    
    public string finalURL{get;set;}
    public string message{get;set;}
    public string wallAlbumId;
    public string errorText{get;set;}
    public string redirecURL{get;set;}
    
    Account linkToContact;
        
    public PostWithImage(ApexPages.StandardController controller) {
    
        retId = ApexPages.currentPage().getParameters().get('id');
        string isLinkingToCampaign = ApexPages.currentPage().getParameters().get('isLinking'); // get Query string if "Post & Link To Campaign" clicked
        
        linkToContact = new Account();
                
        feedObjRef = [select Id,Name,Facebook_User__c,Facebook_User__r.Name,Facebook_User__r.User_ID__c,Facebook_User__r.Access_Token__c,
                        Facebook_Page__r.Access_Token__c,Facebook_Page__r.Facebook_User__r.id,Facebook_Page__r.Wall_Album_Id__c,
                        Facebook_Page__c,Facebook_Page__r.Name,Facebook_Page__r.Facebook_ID__c,Post_On_Page_Wall__c,External_ID__c 
                        from Facebook_Feeds__c where Id =: retId];
    
        userObjRef=[Select f.User_ID__c, f.Name__c,f.About_Me__c, f.Name, f.Id, f.Email__c, f.Country__c, f.Birthday__c,f.Wall_Album_Id__c 
                        From Facebook_User__c f where id=:feedObjRef.Facebook_Page__r.Facebook_User__c OR id=:feedObjRef.Facebook_User__c];
    
        if(feedObjRef.Facebook_Page__c!=null)
            pageObjRef=[select p.Facebook_ID__c, p.Wall_Album_Id__c from Facebook_Pages__c p where p.id=:feedObjRef.Facebook_Page__c];
        
        linkToContact = [Select Id from Account where FacebookID__c =:userObjRef.User_ID__c];
        
        redirecURL='';
        if(feedObjRef.Facebook_Page__c!=null)    // if user has selected "Facebook Page" in feed
            redirecURL='/a0W/e?CF00NE00000038ucU='+feedObjRef.Name+'&CF00NE00000038ucU_lkid='+feedObjRef.id+'&CF00NE0000002KmFy='+feedObjRef.Facebook_Page__r.Name+'&CF00NE0000002KmFy_lkid='+feedObjRef.Facebook_Page__c+'&00NE0000002KmGS=Yes&retURL=/'+retId;
        else if(feedObjRef.Facebook_User__c!=null)    //if user has selected "Facebook User" in feed
            redirecURL='/a0W/e?CF00NE00000038ucU='+feedObjRef.Name+'&CF00NE00000038ucU_lkid='+feedObjRef.id+'&CF00NE0000002KmFo='+feedObjRef.Facebook_User__r.Name+'&CF00NE0000002KmFo_lkid='+feedObjRef.Facebook_User__c+'&00NE0000002KmGS=Yes&retURL=/'+retId;
    }
    
    public void finalPostURL()
    {
        try
        {
            wallAlbumId='';
            errorText='';
            
            if(feedObjRef.Facebook_Page__c!=null && pageObjRef!=null)
            {
                if(pageObjRef.Wall_Album_Id__c!=null)
                    wallAlbumId=pageObjRef.Wall_Album_Id__c;
                else
                    wallAlbumId=createAlbum();
            }
            else if(feedObjRef.Facebook_User__c!=null && userObjRef!=null)
            {
                if(userObjRef.Wall_Album_Id__c!=null)
                    wallAlbumId=userObjRef.Wall_Album_Id__c;
                else
                    wallAlbumId=createAlbum();
            }
            
            String postOnFeedURL='';
            String encodeString ='';
            
            if(feedObjRef.Post_On_Page_Wall__c != null)
                encodeString = EncodingUtil.urlEncode(feedObjRef.Post_On_Page_Wall__c, 'UTF-8'); // encoding the user input string using 'UTF-8' encoding scheme
            
            if(feedObjRef.Facebook_Page__c!=null)    // if user has selected "Facebook Page" in feed
                postOnFeedURL='https://graph.facebook.com/'+wallAlbumId+'/photos?message='+encodeString+'&access_token='+feedObjRef.Facebook_Page__r.Access_Token__c;
            else if(feedObjRef.Facebook_User__c!=null)    //if user has selected "Facebook User" in feed
                postOnFeedURL='https://graph.facebook.com/'+wallAlbumId+'/photos?message='+encodeString+'&access_token='+feedObjRef.Facebook_User__r.Access_Token__c;
            
            system.debug('encodeString >>>>>>>>>>>>>>>>>>'+encodeString);
            
            if(postOnFeedURL!='')
            {
                finalURL=postOnFeedURL ;
            }
            else
            {
                system.debug('returning ................'+postOnFeedURL );
            }
        }
        catch(exception e)
        {          
            system.debug('****Exception *****' + e.getmessage());
        }
    }
    
    public void saveResponse()
    {
        try
        {
            //ADDED on 08/29/2012 for updating feedObjRef.External_ID__c with response received from posting
            string resp1=ApexPages.currentPage().getParameters().get('response');
            errorText='';
            
            if(resp1 != null) 
            {
                Map<String, Object> responsedataMap = (Map<String, Object>)JSON.deserializeUntyped(resp1);
                
                if(responsedataMap != null && responsedataMap.size() > 0 && responsedataMap.get('error') != null)
                {
                    errorText=string.valueOf(responsedataMap.get('error'));
                }
                else if(responsedataMap != null && responsedataMap.size() > 0 && responsedataMap.get('id') != null) 
                {
                    system.debug('responsedataMap.get(post_id) -----> ' + responsedataMap.get('post_id'));
                    system.debug('responsedataMap -----> ' + responsedataMap);
                    
                    /*if(feedObjRef.Facebook_Page__c!=null)
                        feedObjRef.External_ID__c = pageObjRef.Facebook_ID__c+'_'+string.valueOf(responsedataMap.get('id'));
                    else if(feedObjRef.Facebook_User__c!=null)
                        feedObjRef.External_ID__c = feedObjRef.Facebook_User__r.User_ID__c+'_'+string.valueOf(responsedataMap.get('id'));*/
                    
                    feedObjRef.External_ID__c = string.valueOf(responsedataMap.get('post_id'));
                    feedObjRef.Username__c = userObjRef.Name;
                    feedObjRef.Full_Name__c = userObjRef.Name__c;
                    feedObjRef.Profile_Link__c = 'http://www.facebook.com/'+userObjRef.User_ID__c;
                    feedObjRef.External_ID2__c = userObjRef.User_ID__c;
                    if(userObjRef.Birthday__c != null)
                    {
                        feedObjRef.Age__c = System.Today().year() - userObjRef.Birthday__c.year();
                    }
                    feedObjRef.Location__c = userObjRef.Country__c;
                    feedObjRef.About__c = userObjRef.About_Me__c;
                    feedObjRef.Email_Address__c = userObjRef.Email__c;
                    feedObjRef.Link__c = 'http://www.facebook.com/'+string.valueOf(responsedataMap.get('id'));
                    feedObjRef.Link_to_Contact_Record__c = linkToContact.Id;
                    
                    update feedObjRef;
                }
            }
        }
        catch(exception e)
        {
            system.debug('****Exception *****' + e.getmessage());
        }
    }
    
    public string createAlbum()
    {
        string createAlbumPostURL='';
        string albumId='';
        
        if(feedObjRef.Facebook_Page__c!=null)    // if user has selected "Facebook Page" in feed
            createAlbumPostURL='https://graph.facebook.com/'+pageObjRef.Facebook_ID__c+'/albums?name=wall+photos&access_token='+feedObjRef.Facebook_Page__r.Access_Token__c;
        else if(feedObjRef.Facebook_User__c!=null)    //if user has selected "Facebook User" in feed
            createAlbumPostURL='https://graph.facebook.com/'+feedObjRef.Facebook_User__r.User_ID__c+'/albums?name=wall+photos&access_token='+feedObjRef.Facebook_User__r.Access_Token__c;
        
        //system.debug('encodeString >>>>>>>>>>>>>>>>>>'+encodeString);
        
        if(createAlbumPostURL!='')
        {
            Http h1 = new Http();
            HttpRequest hreq1 = new HttpRequest();
            hreq1.setEndpoint(createAlbumPostURL);
            hreq1.setMethod('POST');
            HttpResponse hres1 = h1.send(hreq1);
            String resp1 = hres1.getBody();
            system.debug('<<<<<<<<<<<<<<<<<<<<<< resp1 >>>>>>>>>>>>'+resp1);  
            
            //ADDED on 08/29/2012 for updating feedObjRef.External_ID__c with response received from posting
            if(resp1 != null) 
            {
                Map<String, Object> responsedataMap = (Map<String, Object>)JSON.deserializeUntyped(resp1);
                
                if(responsedataMap != null && responsedataMap.size() > 0 && responsedataMap.get('error') != null)
                {
                    errorText=string.valueOf(responsedataMap.get('error'));
                }
                else if(responsedataMap != null && responsedataMap.size() > 0 && responsedataMap.get('id') != null) 
                {
                    //system.debug('responsedataMap -----> ' + responsedataMap.get('id'));
                    //system.debug('responsedataMap -----> ' + responsedataMap.get('id'));
                    
                    albumId=string.valueOf(responsedataMap.get('id'));
                    
                    if(feedObjRef.Facebook_Page__c!=null)
                    { 
                        pageObjRef.Wall_Album_Id__c = albumId;
                        update pageObjRef;
                    }
                    else if(feedObjRef.Facebook_User__c!=null)
                    {
                        userObjRef.Wall_Album_Id__c = albumId;
                        update userObjRef;
                    }
                }
            }
        }
        
        return albumId;
    }
}
public with sharing class testCreateAlbum {


    public String retId{get;set;} 

    public PageReference pr;
    public Facebook_Feeds__c feedObjRef{get;set;}
    public Facebook_Pages__c pageObjRef;
    public Facebook_User__c userObjRef;
    
    public string finalURL{get;set;}

    
    public testCreateAlbum(ApexPages.StandardController controller) {
    
        retId = ApexPages.currentPage().getParameters().get('id');
        
        //string isLinkingToCampaign = ApexPages.currentPage().getParameters().get('isLinking'); // get Query string if "Post & Link To Campaign" clicked
                
        feedObjRef = [select Id,Name,Facebook_User__c,Facebook_User__r.Name,Facebook_User__r.User_ID__c,Facebook_User__r.Access_Token__c,Facebook_Page__r.Access_Token__c,Facebook_Page__r.Facebook_User__r.id,Facebook_Page__r.Wall_Album_Id__c,Facebook_Page__c,Facebook_Page__r.Name,Facebook_Page__r.Facebook_ID__c,Post_On_Page_Wall__c,External_ID__c from Facebook_Feeds__c where Id =: retId];
    
        userObjRef=[Select f.User_ID__c, f.Name__c,f.About_Me__c, f.Name, f.Id, f.Email__c, f.Country__c, f.Birthday__c,f.Wall_Album_Id__c From Facebook_User__c f where id=:feedObjRef.Facebook_Page__r.Facebook_User__c OR id=:feedObjRef.Facebook_User__c];
    
    }
    
    public void finalPostURL()
    {
        try
        {
            
            String postOnFeedURL='';
            String encodeString = EncodingUtil.urlEncode(feedObjRef.Post_On_Page_Wall__c, 'UTF-8'); // encoding the user input string using 'UTF-8' encoding scheme
            
            if(feedObjRef.Facebook_Page__c!=null)    // if user has selected "Facebook Page" in feed
                postOnFeedURL='https://graph.facebook.com/'+feedObjRef.Facebook_Page__c+'/albums?name='+encodeString+'&type=wall&access_token='+feedObjRef.Facebook_Page__r.Access_Token__c;
            else if(feedObjRef.Facebook_User__c!=null)    //if user has selected "Facebook User" in feed
                postOnFeedURL='https://graph.facebook.com/'+userObjRef.User_ID__c+'/albums?name='+encodeString+'&type=wall&permissi‌​ons=publish_stream&access_token='+feedObjRef.Facebook_User__r.Access_Token__c;
            
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

}
public with sharing class testPhotoPostController1 {

        public String retId{get;set;} 
        public PageReference pr;
        public Facebook_Feeds__c feedObjRef;
        public Facebook_Pages__c pageObjRef;
        
        public string finalURL{get;set;}
        public string message{get;set;}

        
    public testPhotoPostController1()
    {
        retId = ApexPages.currentPage().getParameters().get('id');
        
        //retId='a0YE0000000NcMS';
        
        //feedObjRef = [select Id,Facebook_Page__c,Post_On_Page_Wall__c from Facebook_Feeds__c where Id =: retId];
        //pageObjRef = [select Id,Facebook_User__r.Access_Token__c from Facebook_Pages__c where Id =: feedObjRef.Facebook_Page__c];
        pr = new PageReference('https://c.na9.visual.force.com/apex/TestPhotoPost');
        pr.setRedirect(true); 
    }
    
  
  public PageReference postOnWall() //method that get called when Post button on Facebook Feed object is clicked and is used to post a message on the page wall
  {
    
    try
    {
        //string imgUrl=ApexPages.currentPage().getParameters().get('param1');
        //system.debug(imgUrl);
        String encodeString =EncodingUtil.urlEncode(message,'UTF-8'); // encoding the user input string using 'UTF-8' encoding scheme
        //string encodeString = EncodingUtil.base64Decode();
          //String postOnFeedURL = 'https://graph.facebook.com/272794492829192/photos?message='+encodeString+'&access_token='+pageObjRef.Facebook_User__r.Access_Token__c; // URL to post messages on RightNobels page..
          String postOnFeedURL = 'https://graph.facebook.com/100002959303232/photos?message='+encodeString +'&access_token=AAACKX0hsMzIBAHImPg2XAXlZC6nzkGkgnjUefOVmig1m3PwRICneTmZBGXqbvpofwLHIwHhHwixHusZBWx1SXlD8KZCrSdJYZAw2uxXovvgZDZD';
          //system.debug('encodeString >>>>>>>>>>>>>>>>>>'+encodeString);
          //Http h1 = new Http();
          //HttpRequest hreq1 = new HttpRequest();
          //hreq1.setEndpoint(postOnFeedURL);
          //hreq1.setMethod('POST');
          //HttpResponse hres1 = h1.send(hreq1);
          //String resp1 = hres1.getBody();
        finalURL=postOnFeedURL ;
          //system.debug('<<<<<<<<<<<<<<<<<<<<<< resp1 >>>>>>>>>>>>'+resp1);  
      if(retId == null)
      {
        system.debug('Not Returning..........');
        return null;
      }
      else
      {
        system.debug('returning ................');
        return null;
      }
    }
    catch(exception e)
        {          
            system.debug('****Exception *****' + e.getmessage());
            return null;
        }
    //return pr;
   }
}
public with sharing class testPhotoPostController {

    public string responseData {get;set;}
    
    public testPhotoPostController()
    {
    }
    
  
  public PageReference postIt() //method that get called when Post button on Facebook Feed object is clicked and is used to post a message on the page wall
  {
    try
    {
        //String encodeString = EncodingUtil.urlEncode(string.valueof('Captured.jpg'),'UTF-8'); // encoding the user input string using 'UTF-8' encoding scheme

        //system.debug('encodeString >>>>>>>>>>>>>>>>>>'+encodeString);
        
        String postOnFeedURL = 'https://graph.facebook.com/100000621044513/feed?message=testing&access_token=AAACKX0hsMzIBAHImPg2XAXlZC6nzkGkgnjUefOVmig1m3PwRICneTmZBGXqbvpofwLHIwHhHwixHusZBWx1SXlD8KZCrSdJYZAw2uxXovvgZDZD';
        
        Http h1 = new Http();
        HttpRequest hreq1 = new HttpRequest();
        hreq1.setEndpoint(postOnFeedURL);
        hreq1.setMethod('POST');
        HttpResponse hres1 = h1.send(hreq1);
        String resp1 = hres1.getBody();
        
        
        Map<String, Object> responsedataMap = (Map<String, Object>)JSON.deserializeUntyped(resp1);
        system.debug('responsedataMap -----> ' + responsedataMap);
        
        if(responsedataMap != null && responsedataMap.size() > 0 && responsedataMap.get('error') != null) 
        {
            ApexPages.Message errorCode = new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot post on user\'s wall');
            ApexPages.addMessage(errorCode);
            return null;
        }
        else if(responsedataMap != null && responsedataMap.size() > 0 && responsedataMap.get('id') != null) 
        {
            system.debug('responsedataMap -----> ' + responsedataMap.get('id'));
            responseData = string.valueOf(responsedataMap);
        }
        return null;
         
    }
    catch(exception e)
    {          
        system.debug('****Exception *****' + e.getmessage());
        
    }
   return null;
   }
   
}
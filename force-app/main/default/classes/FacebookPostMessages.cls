/*
Company : Fujitsu America
Date : July 20,2012
Author : Rohit Sen
Description : This class is used for posting a message on the Facebook Page

History :
*/ 


public with sharing class FacebookPostMessages 
{
    public String retId{get;set;} 
    public PageReference pr;
    public Facebook_Feeds__c feedObjRef;
    public Facebook_Pages__c pageObjRef;
    public Facebook_User__c userObjRef;
    Account linkToContact;
    
    public FacebookPostMessages(ApexPages.StandardController controller) {
        linkToContact = new Account();
        retId = ApexPages.currentPage().getParameters().get('id');
        string isLinkingToCampaign = ApexPages.currentPage().getParameters().get('isLinking'); // get Query string if "Post & Link To Campaign" clicked
        feedObjRef = new Facebook_Feeds__c();        
        feedObjRef = [select Id,Name,Facebook_User__c,Facebook_User__r.Name,Facebook_User__r.User_ID__c,
                        Facebook_User__r.Access_Token__c,Facebook_Page__r.Facebook_User__r.Access_Token__c,
                        Facebook_Page__r.Facebook_User__r.id,Facebook_Page__c,Facebook_Page__r.Name,Facebook_Page__r.Facebook_ID__c,
                        Facebook_Page__r.Access_Token__c,Post_On_Page_Wall__c,External_ID__c
                        from Facebook_Feeds__c where Id =: retId];
        
        //if(feedObjRef.Facebook_User__c!=null || feedObjRef.Facebook_Page__r.Facebook_User__c!=null)
        //{
            userObjRef = new Facebook_User__c();
            userObjRef=[Select f.User_ID__c, f.Name__c,f.About_Me__c, f.Name, f.Id, f.Email__c, f.Country__c, f.Birthday__c 
                        From Facebook_User__c f where id=:feedObjRef.Facebook_Page__r.Facebook_User__c OR id=:feedObjRef.Facebook_User__c];
        
            linkToContact = [Select Id from Account where FacebookID__c =:userObjRef.User_ID__c];
        //}
        
        
        if((isLinkingToCampaign=='1')&&(isLinkingToCampaign!=null || isLinkingToCampaign!=''))
        {
            string targetURL='';
            if(feedObjRef.Facebook_Page__c!=null)    // if user has selected "Facebook Page" in feed
                targetURL='/a0W/e?CF00NE00000038ucU='+feedObjRef.Name+'&CF00NE00000038ucU_lkid='+feedObjRef.id+'&CF00NE0000002KmFy='+feedObjRef.Facebook_Page__r.Name+'&CF00NE0000002KmFy_lkid='+feedObjRef.Facebook_Page__c+'&00NE0000002KmGS=Yes&retURL=/'+retId;
            else if(feedObjRef.Facebook_User__c!=null)    //if user has selected "Facebook User" in feed
                targetURL='/a0W/e?CF00NE00000038ucU='+feedObjRef.Name+'&CF00NE00000038ucU_lkid='+feedObjRef.id+'&CF00NE0000002KmFo='+feedObjRef.Facebook_User__r.Name+'&CF00NE0000002KmFo_lkid='+feedObjRef.Facebook_User__c+'&00NE0000002KmGS=Yes&retURL=/'+retId;
            pr = new PageReference(targetURL);
        }
        else
            pr = new PageReference('/' +retId);     // simply Post and return back to Feed 
        
        pr.setRedirect(true);
    }
    
    public PageReference postOnWall() //method that get called when Post button on Facebook Feed object is clicked and is used to post a message on the page wall
    {
        system.debug('retId >>>>>>>>>>>>>>>'+retId);
        system.debug('feedObjRef >>>>>>>>>>>>>>>>>'+feedObjRef);
        
        try
        {
            if(feedObjRef.External_ID__c!=null)    // if message already posted
            {
                ApexPages.Message msgAlreadyPosted = new ApexPages.Message(ApexPages.Severity.ERROR, 'Message already posted.');
                ApexPages.addMessage(msgAlreadyPosted);
                return null;
            }
            else if(feedObjRef.Post_On_Page_Wall__c==null || feedObjRef.Post_On_Page_Wall__c=='')    // if message already posted
            {
                ApexPages.Message errorMsg= new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot post empty message.');
                ApexPages.addMessage(errorMsg);
                return null;
            }
            else
            {
                String postOnFeedURL='';
                String encodeString = EncodingUtil.urlEncode(feedObjRef.Post_On_Page_Wall__c, 'UTF-8'); // encoding the user input string using 'UTF-8' encoding scheme
                
                if(feedObjRef.Facebook_Page__c!=null)    // if user has selected "Facebook Page" in feed
                    postOnFeedURL='https://graph.facebook.com/'+feedObjRef.Facebook_Page__r.Facebook_ID__c+'/feed?message='+encodeString+'&access_token='+feedObjRef.Facebook_Page__r.Access_Token__c;
                else if(feedObjRef.Facebook_User__c!=null)    //if user has selected "Facebook User" in feed
                    postOnFeedURL='https://graph.facebook.com/'+feedObjRef.Facebook_User__r.User_ID__c+'/feed?message='+encodeString+'&access_token='+feedObjRef.Facebook_User__r.Access_Token__c;
                //else if(feedObjRef.Person_Account__c!=null)    //if user has selected "Person account" in feed
                  //  postOnFeedURL='https://graph.facebook.com/'+feedObjRef.Person_Account__r.FacebookID__c+'/feed?message='+encodeString+'&access_token='+feedObjRef.Person_Account__r.Access_Token__c;
                
                system.debug('encodeString >>>>>>>>>>>>>>>>>>'+encodeString);
                
                if(postOnFeedURL!='')
                {
                    Http h1 = new Http();
                    HttpRequest hreq1 = new HttpRequest();
                    hreq1.setEndpoint(postOnFeedURL);
                    hreq1.setMethod('POST');
                    HttpResponse hres1 = h1.send(hreq1);
                    String resp1 = hres1.getBody();
                    system.debug('<<<<<<<<<<<<<<<<<<<<<< resp1 >>>>>>>>>>>>'+resp1);  
                    
                    //ADDED on 08/29/2012 for updating feedObjRef.External_ID__c with response received from posting
                    if(resp1 != null) {
                        Map<String, Object> responsedataMap = (Map<String, Object>)JSON.deserializeUntyped(resp1);
                        
                        if(responsedataMap != null && responsedataMap.size() > 0 && responsedataMap.get('error') != null)
                        {
                            ApexPages.Message msgCannotPost = new ApexPages.Message(ApexPages.Severity.ERROR, string.valueOf(responsedataMap.get('error')));
                            ApexPages.addMessage(msgCannotPost);
                            return null;
                        }
                        else if(responsedataMap != null && responsedataMap.size() > 0 && responsedataMap.get('id') != null) 
                        {
                            system.debug(feedObjRef +'   --- responsedataMap -----> ' + responsedataMap.get('id'));
                            feedObjRef = new Facebook_Feeds__c(Id=retId);
                            feedObjRef.External_ID__c = string.valueOf(responsedataMap.get('id'));
                            system.debug('R1 - '+feedObjRef.External_ID__c);
                            feedObjRef.Link__c = 'http://www.facebook.com/'+string.valueOf(responsedataMap.get('id'));
                            system.debug('R2 - '+feedObjRef.Link__c);
                            feedObjRef.Username__c = userObjRef.Name;
                            system.debug('R3 - '+feedObjRef.Username__c);
                            feedObjRef.Full_Name__c = userObjRef.Name__c;
                            system.debug('R4 - '+feedObjRef.Full_Name__c);
                            feedObjRef.Profile_Link__c = 'http://www.facebook.com/'+userObjRef.User_ID__c;
                            system.debug('R5 - '+feedObjRef.Profile_Link__c);
                            feedObjRef.External_ID2__c = userObjRef.User_ID__c;
                            system.debug('R6 - '+feedObjRef.External_ID2__c);
                            if(userObjRef.Birthday__c != null)
                            {
                                feedObjRef.Age__c = System.Today().year() - userObjRef.Birthday__c.year();
                            }
                            feedObjRef.Location__c = userObjRef.Country__c;
                            feedObjRef.About__c = userObjRef.About_Me__c;
                            feedObjRef.Email_Address__c = userObjRef.Email__c;
                            feedObjRef.Link_to_Contact_Record__c = linkToContact.id;

                            update feedObjRef;
                        }
                    }
                }

                if(retId == null)
                {
                    system.debug('Not Returning..........');
                    return null;
                }
                else
                {
                    system.debug('returning ................');
                   return pr;
                   
                }
            }
        }
        catch(exception e)
        {           
            system.debug('****Exception *****' + e.getmessage());
            return null;
        }
    }
    
    public pageReference backToFeed()    // if message already posted return back to Feed
    {
        try
        {
            PageReference targetPage = new PageReference('/' +retId);
            targetPage.setRedirect(true);
            return targetPage;
        }
        catch(exception e)
        {           
            system.debug('****Exception *****' + e.getmessage());
            return null;
        }
    }
}
/*
Company : Fujitsu America
Date : August 16,2012
Author : Rohit Sen
Description : This class is used for fetching the likes of comments for a particular messages 
              relative to a Page. Object updated is Facebook Child Feeds. This class is invoked when any Child Feed Record is 
              inserted or being updated. It Implements Email Handler, thus negeting the HTTP Request limit of Salesforce. 
History :
*/ 




global class Get_CommentLikes implements Messaging.InboundEmailHandler 
{	
	//Variable Declarations
	
	public RecordType recordtypeObjRef;
	public Facebook_Child_Feed__c childFeedObj;
	public List<Facebook_Child_Feed__c> childFeedObjectInsertList;
	public Facebook_Child_Feed__c childObjRef;
	
	//End Of Variable Declarations
	
	
	
	
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
    	
    	Messaging.InboundEmailResult result = new Messaging.InboundEmailresult(); 
    	Map<String,Object> likeForCommentMap;
    	
    	childObjRef = new Facebook_Child_Feed__c();
    	
    	
    	
    	try
        {
           
           String strServiceCall = email.subject.trim();  //Service Name
           String strCommentBody = email.plainTextBody;  // PostId
            
           system.debug('Call Services >>>>>>>>>>>>>>>> ' + strServiceCall + ' <<<<<<<<<< Comment Id >>>>>>>>>>>>>>>' +strCommentBody );
            
           if(strServiceCall.contains('Sandbox:'))
           {
               strServiceCall = strServiceCall.Replace('Sandbox:','').trim();
           }
            
           strServiceCall = strServiceCall.trim();
            
           if(strCommentBody.contains('Sandbox:'))
           {
               strCommentBody = strCommentBody.Replace('Sandbox:','').trim();
           }
            
           strCommentBody = strCommentBody.trim();
                   
           system.debug('Comment Id >>>>>>>>>>>>>>> :' + strCommentBody );
           
           
           recordtypeObjRef = [select Id from RecordType where RecordType.Name =: 'Person Account' limit 1];
           
           childObjRef = [select Id,External_ID__c,Facebook_Feed__c,Facebook_Page__c,Facebook_User__c,FBUserId_FeedId_External_Id__c,Feed_Type__c,Link_to_Contact_Record__c,Link_to_Contact_Record__r.Access_Token__c from Facebook_Child_Feed__c where External_ID__c =: strCommentBody];
          
           system.debug('childObjRef >>>>>>>>>>>>>>>>>>>>'+childObjRef); 
           system.debug('Link_to_Contact_Record__r.Access_Token__c >>>>>>>>>>>>'+childObjRef.Link_to_Contact_Record__r.Access_Token__c);
           
           String CommentLikeURL = 'https://graph.facebook.com/'+strCommentBody+'/likes&access_token='+childObjRef.Link_to_Contact_Record__r.Access_Token__c;     
           Http h1 = new Http();
           HttpRequest hreq1 = new HttpRequest();
       	   hreq1.setEndpoint(CommentLikeURL);
           hreq1.setMethod('GET');
           HttpResponse hres1 = h1.send(hreq1);
           String resp1 = hres1.getBody(); 
     
           Map<String, Object> commentLikeMap = (Map<String, Object>)JSON.deserializeUntyped(resp1); // deserializing the JSON Response from facebook.    
           system.debug(commentLikeMap.keySet()+' <<<<<<<<<<<<<< commentLikeMap >>>>>>>>>>>>>>>>'+commentLikeMap);
           List<Object> commentLikeList = (List<Object>)commentLikeMap.get('data');
           system.debug('commentLikeList >>>>>>>>>>>>>>>>>>'+commentLikeList); 
           
         /*  likeForCommentMap = (Map<String, Object>)commentLikeList[0];
           
           system.debug('likeForCommentMap >>>>>>>>>>>>>'+);*/
           
           
           
           
           
           
           
           
           
           
           
           	
        	
        }
    	catch(exception e)
      	{        	
          system.debug('****Exception *****' + e.getmessage());
          return null;
      	}
     return result;
    }
	
}
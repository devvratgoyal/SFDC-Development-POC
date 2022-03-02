/*
	Developer Name : Rohit Sen
	Modified on : 16-07-2012
*/

// Class used for parsing the JSON data that has been passed from OAuth.cls as well as saving various salesforce objects.
public with sharing class FB_JSONParser 
{ 
	
	public FB_JSONParser(){}	
	
	
	
	public void performParsing(String response)
	{
		/* Variable Declarations */
		
		Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(response); // deserializing the JSON Response from facebook.	
		List<Object> dataList = (List<Object>)dataMap.get('data'); //retrieves all information from dataMap with Key - "data"
		Map<String,Object> tempMap = new Map<String,Object>();
		List<String> IdValues;
		List<String> NameValues;
		/* End of Declaration */
		
		
		system.debug('dataList >>>>>>>>>>>>>>>>>>>>>>>>>>>>' +dataList);
		system.debug(dataMap.keySet()+'dataMap >>>>>>>>>>>>>>>>>>>>>>>>>>>>' +dataMap);
		
		
		for(Integer i=0; i<dataList.size(); i++)
		{
			tempMap = (Map<String, Object>)dataList[i];
			system.debug(tempMap.keySet()+'tempMap >>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+tempMap);  //tempMap.keySet() --> {created_time, from, id, message} AND {created_time, from, id, likes, message}
			
			if(tempMap.containsKey('message'))	// if each map element contains the key 'message', then process those fields, else discard
			{
				List<String> details = new List<String>();  //contains  datas after splitting on special character ,[comma]
				IdValues = new List<String>();  // will contain all the Ids of users who have posted a message
				NameValues = new List<String>();  //will contain all the names of users who have posted a message
				String userData = tempMap.get('from')+'';  //retrieves all information from messageMap with Key - "data"
				
				system.debug('userData outside if >>>>>>>>>>>>>>>>>'+userData);
				if(!userData.contains('category'))  // will consider those datas that doesn't contain the substring "category" in it
				{
					system.debug('userData inside if >>>>>>>>>>>>>>>>>'+userData);
					userData = userData.replace('{',''); 
					userData = userData.replace('}','');
					details = userData.split(',');
					system.debug(details.size()+'      details >>>>>>>>>>>>>>>>>>>>'+details);
					for(Integer j=0; j< details.size();j++)
					{
						if(details[j].contains('id='))
						{
							IdValues = details[j].split('id=');
							system.debug('j >>>>>>>>>'+j+'  IdValues >>>>>>>>>>>>>>>>>>>>>>>>>>>>' +IdValues);
						
						}
					
						if(details[j].contains('name='))
						{
							NameValues = details[j].split('name=');
							system.debug('j >>>>>>>>>'+j+'  NameValues >>>>>>>>>>>>>>>>>>>>>>>>>>>>' +NameValues);
						}
				
					}
				
				}
			}
			
			
		}
	
	system.debug(IdValues.size()+'IdValues >>>>>>>>>>>>>>>>>>>>>>>>>>>>' +IdValues);
	system.debug(NameValues.size()+'NameValues >>>>>>>>>>>>>>>>>>>>>>>>>>>>' +NameValues);
	
	
	
	}
	
	
	
	
/*		
	public void performParsing(String responseForMessage)
	{
		
	//	******************** Deserializing the JSON for PAGE MESSAGES/USER who posts users *****************
		
	 	
		Map<String, Object> messageMapFinal = new Map<String, Object>(); // used to store data from first serialization of JSON data..
		List<FB_Page_Messages__c> checkDuplicateMsgList = new List<FB_Page_Messages__c>();
		
		
		Map<String, Object> messageMap = (Map<String, Object>)JSON.deserializeUntyped(responseForMessage); // deserializing the message Response from facebook.	
		List<Object> listOfMessage = (List<Object>)messageMap.get('data'); //retrieves all information from messageMap with Key - "data"
				
		Set<String> fbMsgIds = new Set<String>();
		system.debug('checkDuplicateMsgList------>' + checkDuplicateMsgList);
		checkDuplicateMsgList = [select Name from FB_Page_Messages__c]; //retrieve all name from message object and is used for preventing duplicate entries
		
		if(checkDuplicateMsgList.size() != 0)
		{
			for(FB_Page_Messages__c fb : checkDuplicateMsgList) //filling a set "fbMsgIds" with Ids fetched from created objects..
			{
				fbMsgIds.add(fb.Name);
			}
		}
				
		system.debug('fbMsgIds------>' + fbMsgIds);
		
		Set<String> fbUserIdSet = new Set<String>();
		List<String> fbUserIdLst = new List<String>();
		List<FB_Page_Messages__c> createMessageRecordLst = new List<FB_Page_Messages__c>();
		Map<String,FB_Page_Messages__c> messageMap1 = new Map<String,FB_Page_Messages__c>();//key-postid,value=fbuid
		Map<String,String> userDetailsFromMessageMap = new Map<String,String>(); //key-fbuid,value=fbuname
		
		system.debug(listOfMessage.size()+'<<<<<<<<<<<<<<<<<<<<<<<<< listOfMessage >>>>>>>>>>>>>>>>>>>>>' +listOfMessage);
		
		for(Integer i=0;i<listOfMessage.size();i++)
		{
			messageMapFinal = (Map<String, Object>)listOfMessage[i];
			if(messageMapFinal.containsKey('message'))   // if each map element contains the key 'message', then process those fields, else discard
			{
				List<String> details = new List<String>();  //contains  datas after splitting on special character ,[comma]
				List<String> IdValues = new List<String>();  // will contain all the Ids of users who have posted a message
				List<String> NameValues = new List<String>();  //will contain all the names of users who have posted a message
				String userData=messageMapFinal.get('from')+'';  //retrieves all information from messageMap with Key - "data"
				userData=userData.replace('{',''); 
				userData=userData.replace('}','');
				details=userData.split(',');
				IdValues=details[0].split('id=');  // inserting all userIds after splitting on 'id='
				NameValues=details[1].split('name=');  // inserting all usernames after splitting on 'name='
				
				system.debug(NameValues+'<<<<<<<<<<<<<<< IdValues >>>>>>>>>>>>>>'+IdValues);
				system.debug('<<<<<<<<<<<<<< IdValues.size() , NameValues.size() >>>>>>>>>>>>>>'+IdValues.size()+ ' , ' + NameValues.size());
				if(IdValues.size()>1 && NameValues.size()>1)   //will execute only when both the List are not null..
				{
					FB_Page_Messages__c fbMessageRecord;  // creating message objects
					
					if(fbMsgIds.contains(messageMapFinal.get('id')+'')==false)  //will execute only if id from messageMapFinal is not contained in set fbMsgIds [means that the values are new and it prevents duplicate entries on objects]
					{
						fbMessageRecord = new FB_Page_Messages__c(Name = String.valueOf(messageMapFinal.get('id')),Fb_User_Id__c=IdValues[1],Posts__c = String.valueOf(messageMapFinal.get('message')));
						createMessageRecordLst.add(fbMessageRecord);
						messageMap1.put(messageMapFinal.get('id')+''+IdValues[1],fbMessageRecord);  // map contains all the message Ids as Key and the message Object in each value corresponding to the message Id Key..
					}
					
					userDetailsFromMessageMap.put(IdValues[1],NameValues[1]);  // Map contains all the user IDs and it corresponding UserNames
					fbUserIdSet.add(IdValues[1]);    //set contains all userIds
					fbUserIdLst.add(IdValues[1]);	//List contains all userIds
				}
			}
		}
		system.debug('> fbUserIdSet <<<<<<<<<<<<<<<<<<<<<<'+fbUserIdSet);
		Set<String> userFBIdSet = new Set<String>();  // Set contains all the Facebook Ids of users..
		Map<String,FB_Page_Users__c> userDetailMap = new Map<String,FB_Page_Users__c>(); // Key - UserId, Value - User Object
		
		FB_Page_Users__c[] userDetails = [select Id,Name,Name__c from FB_Page_Users__c where Name__c IN:fbUserIdSet]; //fetching records from UserObject

		if (userDetails.size()>0)  //wil execute when records are present in User Object
		{
			system.debug('<<<<<<<<<<<<< Inside If>>>>>>>>>>>>>>'+userDetails.size());
			for (Integer i=0;i<userDetails.size();i++)
			{
				userDetailMap.put(userDetails[i].Name__c,userDetails[i]);
				userFBIdSet.add(userDetails[i].Name__c);
				system.debug('><<<<<<<<<<<<< userDetails >>>>>>>>>>>>>>>>>>'+userDetails[i]);
			}
		}
		
		List<FB_Page_Users__c> createUserLst = new List<FB_Page_Users__c>(); //list used to contain User Objects that will be inserted
		system.debug('<<<<<<<<<< fbUserIdLst >>>>>>>>>>.'+fbUserIdLst);
		for(Integer i=0; i<fbUserIdLst.size(); i++)
		{
			if(userDetailsFromMessageMap.containsKey(fbUserIdLst[i]) && userFBIdSet.contains(fbUserIdLst[i])==false) // will execute only when UserId is present in userDetailsFromMessageMap Map UserId not present in set userFBIdSet [means that all the userIds are new and are not already present in User Object, thus preventing duplicacy]
			{
				createUserLst.add(new FB_Page_Users__c(Name__c = fbUserIdLst[i],Name = userDetailsFromMessageMap.get(fbUserIdLst[i]))); //object added in list
			}
		}
		insert createUserLst; //user object inserted
		System.debug(createUserLst+'********createUserLst');
		for(Integer i=0;i<createUserLst.size();i++)
		{
			userDetailMap.put(createUserLst[i].Name__c,createUserLst[i]); //userDetailMap updated with new userIds and User Objects
		}
			
		for(Integer i=0;i<createMessageRecordLst.size();i++)
		{
			//fbMessageRecord=new FB_Page_Messages__c(Name = String.valueOf(messageMapFinal.get('id')),Fb_User_Id__c=IdValues[1],Posts__c = String.valueOf(messageMapFinal.get('message')));
			System.debug('****test**'+createMessageRecordLst[i].Name+''+createMessageRecordLst[i].Fb_User_Id__c);
			if(messageMap1.containsKey(createMessageRecordLst[i].Name+'' + createMessageRecordLst[i].Fb_User_Id__c) &&
			    userDetailMap.containsKey(createMessageRecordLst[i].Fb_User_Id__c) && fbMsgIds.contains(createMessageRecordLst[i].Name)==false) //will execute when messageMap1 contains the MessageId and its UserId corresponding to its messageId as its key and userDetailMap contains the UserId for the message and set fbMsgIds doesn't contain the messageId
			    {
					createMessageRecordLst[i].FB_Page_Users_Id__c = userDetailMap.get(createMessageRecordLst[i].Fb_User_Id__c).Id; // for each message its corresponding FBUserId is inserted after fetching the details from userDetailMap Map against key Id
				}			
			
		}	
		insert createMessageRecordLst;  //message object Inserted
		
		
		
		//******************* Deserializing the JSON for USER liking on MESSAGES ******************
		
		Map<String, Object> likeMap = (Map<String, Object>)JSON.deserializeUntyped(responseForMessageLikes); // deserializing the message Response from facebook.	
		List<Object> listOfMessageLikes = (List<Object>)likeMap.get('data'); //retrieves all information from messageMap with Key - "data"
		system.debug(listOfMessageLikes.size()+'listOfMessageLikes>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+listOfMessageLikes);
		Map<String, Object> likeMapFinal = new Map<String, Object>();
		String userLikeData;
		Map<String,Object> userLikeDatatest;
		List<String> LikeMessagestemp = new List<String>();
		List<String> UserLikeMessagesData = new List<String>();
			
		for(Integer i=0;i<listOfMessageLikes.size();i++)
		{
			likeMapFinal = (Map<String, Object>)listOfMessageLikes[i];
			system.debug(likeMapFinal+' >>>>>>>>>>>>>>>>> likeMapFinal <<<<<<<<<<<<<<<<<'+likeMapFinal.keySet());
			
			if(likeMapFinal.containsKey('likes'))   // if each map element contains the key 'likes', then process those fields, else discard
			{	
				 system.debug('rohit..... >>>'+likeMapFinal.get('likes'));
				 userLikeDatatest = (Map<String,Object>)likeMapFinal.get('likes');  //retrieves all information from messageMap with Key - "data"
				 userLikeData = String.valueOf(userLikeDatatest.get('data'));					 
				 List<String> IdValues = new List<String>();  // will contain all the Ids of users who have liked a message
				 List<String> NameValues = new List<String>();  //will contain all the names of users who have liked a message
							 
				 system.debug(userLikeDatatest.keySet()+'userLikeDatatest >>>>>>>>>>>>>>>>>>'+userLikeDatatest);

				 userLikeData = userLikeData.replace('{','');
				 userLikeData = userLikeData.replace('}','');
				 system.debug('userLikeData >>>>>>>>>>>>>>>>>>>>>>'+userLikeData);		 
				 LikeMessagestemp = userLikeData.split(',');
				 
				 for(Integer b=0 ; b< LikeMessagestemp.size(); b++)
				 {
				 	if(LikeMessagestemp[b].contains('id='))
				 	{
				 		IdValues = LikeMessagestemp[b].split('id=');
				 	}
				 	if(LikeMessagestemp[b].contains('name='))
				 	{
				 		NameValues = LikeMessagestemp[b].split('name=');
				 	}
				 }
				 				 					    		 
				// UserLikeMessagesData.add(userLikeData);
			
			
				system.debug('LikeMessagestemp >>>>>>>>>>>>>>>>>>>>>>>'+LikeMessagestemp);
				system.debug('IdValues >>>>>>>>>>>>>>>>>>>>>>>'+IdValues);
				system.debug('NameValues >>>>>>>>>>>>>>>>>>>>>>>'+NameValues);
				for(Integer k=0;k<UserLikeMessagesData.size();k++)
				{
					if(UserLikeMessagesData[k] != null)
					{
						userTemp = UserLikeMessagesData[k].substring(t1+1,t2-1);
					}
				}
				 			
			}	
		}
		//system.debug(userTemp+'      UserLikeMessagesData >>>>>>>>>>>>>>>>>>>>>>> '+UserLikeMessagesData);
			
		
		
		
	} 	*/
	


}
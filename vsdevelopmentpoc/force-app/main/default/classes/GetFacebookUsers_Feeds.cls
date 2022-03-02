public with sharing class GetFacebookUsers_Feeds{  
    
    // Variable Decalration
    public Facebook_User__c fbUserRef;
    public String userRetId{get;set;}
    public Id rtInbound,rtOutbound;
    public String postById,postByName;
    public Map<String,String> postDataMap;
    public Facebook_Feeds__c fbFeedObj;
    public String likeByUserId,likeByUserName;
    public Set<String> postToDelete;
    public List<Facebook_Feeds__c> fbFeedObjectInsertList;
    public Object postLikeByUser;
    public List<Account> accountList;
    public Map<String,Account> personAccountMap;
    public RecordType recordtypeRef;
    public Account accountObj;
    public List<Account> accountforFbusersList;
    // End of variable Declaration
    
    public GetFacebookUsers_Feeds (ApexPages.StandardController controller){
    	fbUserRef = (Facebook_User__c)controller.getRecord(); 
    	userRetId = fbUserRef.Id;
    	recordtypeRef = [select Id from RecordType where DeveloperName = 'PersonAccount' AND SobjectType = 'Account'];
    	for(RecordType[] rt:[SELECT Id,Name,DeveloperName FROM RecordType WHERE (DeveloperName = 'Inbound' OR DeveloperName = 'Outbound') AND SobjectType = 'Facebook_Feeds__c' LIMIT 2]){
        	for(RecordType r:rt){
        		if(r.DeveloperName == 'Inbound'){
        			rtInbound = r.Id;
        		}else if(r.DeveloperName == 'Outbound'){
        			rtOutbound = r.Id;
        		}
        	}
        } 
    }
    
    public PageReference getFacebookUsers_Data(){
    	try{
    		postDataMap = new Map<String,String>();
    		postToDelete = new Set<String>();
    		fbFeedObjectInsertList = new List<Facebook_Feeds__c>();
    		Map<String,String> likeByUserMap = new Map<String,String>();
    		Set<String> childExtIds = new Set<String>();
    		accountList = new List<Account>();
    		personAccountMap = new Map<String,Account>();
    		accountforFbusersList = new List<Account>();
    		
    		// Http request to facebook to retrieve the Post and PostedBy Information of Users Wall..
        	String userFeedURL = 'https://graph.facebook.com/'+fbUserRef.User_ID__c+'/feed?fields=message,from,likes,picture&limit=1000&access_token='+fbUserRef.Access_Token__c;        
        	Http h1 = new Http();
        	HttpRequest hreq1 = new HttpRequest();
        	hreq1.setEndpoint(userFeedURL);
        	hreq1.setMethod('GET');
        	HttpResponse hres1 = h1.send(hreq1);
        	String resp1 = hres1.getBody();
    		
    		Schema.DescribeFieldResult fieldResult = Facebook_Feeds__c.Feed_Type__c.getDescribe(); // used to get the values of the picklist
        	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    	
    		Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(resp1); // deserializing the JSON Response from facebook.    
        	List<Object> dataList = (List<Object>)dataMap.get('data'); //retrieves all information from dataMap with Key - "data"
    		
    		Map<String,Object> tempMap = new Map<String,Object>();
        	Map<String,Object> fromMap;        
        	Map<String,Object> likeMap;
    		
    		if(dataList.size() > 0){
	    		for(Integer i = 0; i < dataList.size();i++){
	    			tempMap = (Map<String,Object>)dataList[i];
	    			system.debug(tempMap.keySet()+'    tempMap >>>>>>>>>>>> '+tempMap);
	    			if(tempMap.containsKey('message')){  // will only iterate if feed contains a Key message
	            		fbFeedObj = new Facebook_Feeds__c();
	            	
	            		fbFeedObj.External_ID__c = 	tempMap.get('id')+'';
	            		fbFeedObj.Message__c = tempMap.get('message')+'';
	            		
	            		for(Schema.PicklistEntry p : ple){   
	                   		if(p.getLabel().contains('Wall Post') && p.isActive() == true){   
	                       		fbFeedObj.Feed_Type__c = p.getValue();
	                   		} 
	                	}  
	                	
	                	fbFeedObj.Link__c = 'http://www.facebook.com/'+tempMap.get('id')+'';      
	            		
	            		fromMap = new Map<String,Object>(); // map contains information of Facebook Users posting a message [keySet - (id,name)/ or (id,name,category) , values - ('123','Username')]
	  		 			fromMap = (Map<String,Object>)tempMap.get('from');
	  		 		
						if(fromMap.containsKey('category')){ // means this has been posted by the Page, so details of the page admin should be populated
							postByName = fbUserRef.Name__c; 				
							postById = fbUserRef.User_ID__c;
							postDataMap.put(postById,postByName);				
						
						}else{  // normal facebook user has posted a message in facebook
							postByName = fromMap.get('name')+''; 				
							postById = fromMap.get('id')+'';
							postDataMap.put(postById,postByName);
						}
		          		
		          		fbFeedObj.External_ID2__c = postById; 
		          		fbFeedObj.Full_Name__c = postByName;
		          		fbFeedObj.RecordTypeId = rtInbound;
		          			            	
		            	if(postById == fbUserRef.User_ID__c){
		  		 			fbFeedObj.Facebook_User__c = fbUserRef.Id;
		  		 		}else{
		  		 			fbFeedObj.Facebook_User__c = null;
		  		 		}
		  		 		
		  		 		if(tempMap.containsKey('likes')){
		  		 			likeMap = new Map<String,Object>();
		  		 			likeMap = (Map<String,Object>)tempMap.get('likes');  		 			
		  		 				  		 			
		  		 			//fbFeedObj.Post_Likes__c = (Decimal)likeMap.get('count');
		  		 			
		  		 			postLikeByUser = (Object)likeMap.get('data');  		 			
		  		 			String newJSON = JSON.serialize(postLikeByUser);  //serializing object x. This JSON contains all the comment data relative to a message   		
							  	   
		  		 			List<Object> list1 = (List<Object>)JSON.deserializeUntyped(newJSON); // deserializing the JSON Response from facebook.    
		        			  		 			
		  		 			Map<String,Object> newMap = new Map<String,Object>();  		 			
		  		 			
		  		 			
		  		 			for(Integer k = 0; k < list1.size(); k++){
		  		 				newMap = (Map<String,Object>)list1[k];
		  		 				if(!(newMap.containsKey('category'))){
	  		 						likeByUserMap.put(newMap.get('id')+'',newMap.get('name')+'');
	  		 					}else{
	  		 						likeByUserMap.put(fbUserRef.User_ID__c,fbUserRef.Name__c);
	  		 					} 
		  		 			} 
		  		 		}
			  		 	if(tempMap.containsKey('picture')){ // if any picture is also posted along with the message
		  		 			String photoURL = tempMap.get('picture')+'';
		  		 			String photoUrlHTML = '<img src="'+photoURL+'" height="42" width="42" />';
		  		 			fbFeedObj.Photo__c = photoUrlHTML;
		  		 			//fbFeedObj.Link__c = tempMap.get('link')+'';
		  		 			
		  		 		}  		 		
		  		 		
		            	fbFeedObjectInsertList.add(fbFeedObj); 
		            	childExtIds.add(fbFeedObj.External_ID__c);  
		  		 		postToDelete.add(tempMap.get('id')+'');	
	            		
	            	}else if(tempMap.containsKey('picture') && (!tempMap.containsKey('message'))){ // This part will execute when a post contains only a 
		            	
		            	fbFeedObj = new Facebook_Feeds__c();
		            	
		            	fbFeedObj.External_ID__c = 	tempMap.get('id')+'';
		            	fbFeedObj.Message__c = null;
		            	
		            	for(Schema.PicklistEntry p : ple){   
		                   	if(p.getLabel().contains('Wall Post') && p.isActive() == true){   
		                       	fbFeedObj.Feed_Type__c = p.getValue();
		                   	}
		                }                    	
		  		 		
		  		 		system.debug('');
		  		 		
		  		 		fbFeedObj.Link__c = 'http://www.facebook.com/'+tempMap.get('id')+'';
		  		 		fbFeedObj.RecordTypeId = rtInbound;
		  		 		fromMap = new Map<String,Object>(); // map contains information of Facebook Users posting a message [keySet - (id,name)/ or (id,name,category) , values - ('123','Username')]
		  		 		fromMap = (Map<String,Object>)tempMap.get('from');
											
						if(fromMap.containsKey('category')){ // means this has been posted by the Page, so details of the page admin should be populated
							postByName = fbUserRef.Name__c; 				
							postById = fbUserRef.User_ID__c;
							postDataMap.put(postById,postByName);				
						
						}else{  // normal facebook user has posted a message in facebook
							postByName = fromMap.get('name')+''; 				
							postById = fromMap.get('id')+'';
							postDataMap.put(postById,postByName);
						}
		          		
		          		fbFeedObj.External_ID2__c = postById; 
		          		fbFeedObj.Full_Name__c = postByName;
		          		
		          		String photoURL = tempMap.get('picture')+'';
		  		 		String photoUrlHTML = '<img src="'+photoURL+'" height="42" width="42" />';
		  		 		fbFeedObj.Photo__c = photoUrlHTML;         		

		            	
		            	if(postById == fbUserRef.User_ID__c){
		  		 			fbFeedObj.Facebook_User__c = fbUserRef.Id;
		  		 		}else{
		  		 			fbFeedObj.Facebook_User__c = null;
		  		 		}
		  		 		
		  		 		if(tempMap.containsKey('likes')){
		  		 			likeMap = new Map<String,Object>();
		  		 			likeMap = (Map<String,Object>)tempMap.get('likes');  		 			
		  		 				  		 			
		  		 			//fbFeedObj.Post_Likes__c = (Decimal)likeMap.get('count');
		  		 			
		  		 			postLikeByUser = (Object)likeMap.get('data');  		 			
		  		 			String newJSON = JSON.serialize(postLikeByUser);  //serializing object x. This JSON contains all the comment data relative to a message   		
							
					  	   
		  		 			List<Object> list1 = (List<Object>)JSON.deserializeUntyped(newJSON); // deserializing the JSON Response from facebook.    
		        					  		 			
		  		 			Map<String,Object> newMap = new Map<String,Object>();  		 			
		  		 			
		  		 			
		  		 			for(Integer k = 0; k < list1.size(); k++){
		  		 				newMap = (Map<String,Object>)list1[k];		  		 				
		  		 				if(!(newMap.containsKey('category'))){
	  		 						likeByUserMap.put(newMap.get('id')+'',newMap.get('name')+'');
	  		 					}else{
	  		 						likeByUserMap.put(fbUserRef.User_ID__c,fbUserRef.Name__c);
	  		 					} 
		  		 			} 
		  		 		}
		            	
		            	fbFeedObjectInsertList.add(fbFeedObj); 
		            	childExtIds.add(fbFeedObj.External_ID__c);  
		  		 		postToDelete.add(tempMap.get('id')+'');  
		            }
	    		} // end of outer for
    		}//end of if
    		
	        Set<String> facebookUserIdFor_PostLikes_PostSet = new Set<String>();  // set contains all the facebook Ids of Facebook users that have posted a message or have liked a particular posts
	        facebookUserIdFor_PostLikes_PostSet.addAll(postDataMap.keySet());
	        facebookUserIdFor_PostLikes_PostSet.addAll(likeByUserMap.keySet());  
	        
	        Map<String,String> allFacebookUserMap = new Map<String,String>();
	        allFacebookUserMap.putAll(likeByUserMap);
	        allFacebookUserMap.putAll(postDataMap);	        
	        Set<String> accIds = new Set<String>();
	        List<Facebook_Feeds__c> tempFeedUpdatedList = new List<Facebook_Feeds__c>();
	        List<Facebook_Feeds__c> tempFeedYetToUpdateList = new List<Facebook_Feeds__c>();
	    	
    		accountList = [select Id,RecordTypeId,FacebookID__c,Name,FBUserName__c,PersonEmail__c,Birthday__c from Account where RecordTypeId =: recordtypeRef.Id AND FacebookID__c IN : allFacebookUserMap.keySet()];
        
	        if(accountList.size() > 0){
	        	for(Account acc : accountList){
	        		personAccountMap.put(acc.FacebookID__c,acc);  //map contains all person account objects relative to its key [Facebook ID]
	        	}
	        }
	        
    		for(Facebook_Feeds__c child : fbFeedObjectInsertList){	
	   			if((personAccountMap.containsKey(child.External_ID2__c))){
	   				child.Link_to_Contact_Record__c = personAccountMap.get(child.External_ID2__c).Id;
	   				child.Full_Name__c = personAccountMap.get(child.External_ID2__c).Name;
	 	 			child.Username__c = personAccountMap.get(child.External_ID2__c).FBUserName__c;
	 	 			child.Profile_Link__c = 'http://www.facebook.com/'+personAccountMap.get(child.External_ID2__c).FBUserName__c;
	   				if(personAccountMap.get(child.External_ID2__c).PersonEmail__c != null){
	 	 				child.Email_Address__c = personAccountMap.get(child.External_ID2__c).PersonEmail__c;
	 	 			}
	 	 			if(personAccountMap.get(child.External_ID2__c).Birthday__c != null){
	 	 				child.Age__c = System.today().year() - personAccountMap.get(child.External_ID2__c).Birthday__c.year();  //calculating the age from birthday
	 	 			}
	 	 	 	 	tempFeedUpdatedList.add(child);	
	   			}else{ 	 
	 	 			tempFeedYetToUpdateList.add(child);			
	 	 			if(!accIds.contains(child.External_ID2__c)){ 	 				
	 	 				accIds.add(child.External_ID2__c);
	 	 				accountObj = new Account();
	 	 				accountObj.Access_Token__c = fbUserRef.Access_Token__c;
	 	 				accountObj.FacebookID__c = child.External_ID2__c;
	 	 				accountObj.RecordTypeId = recordtypeRef.Id;  	 				       	 		
	 	 				List<String> nameofuser = String.valueOf(allFacebookUserMap.get(child.External_ID2__c)).split(' ');   	 	 			
	 	 				accountObj.LastName__c = '';
	 	 				for(Integer s = 0; s < nameofuser.size(); s++){          	 					         	 					
	 	 					if(accountObj.FirstName__c == null){
	 	 						accountObj.FirstName__c = nameofuser[s];
	 	 			   		}else{ 	 		         	 			
	 	 						accountObj.LastName__c = accountObj.LastName__c + ' ' + nameofuser[s];
	 	 			   		}
	 	 				}
	 	 				accountforFbusersList.add(accountObj);       	 		
	 	 			}
	 	 		}  		
	   		}
	   		
	   		for(String sKey:likeByUserMap.keyset()){
	   			if(!accIds.contains(sKey) && !personAccountMap.containsKey(sKey)){
	   				accIds.add(sKey);
	 	 			accountObj = new Account();
	 	 			accountObj.Access_Token__c = fbUserRef.Access_Token__c;
	 	 			accountObj.FacebookID__c = sKey;
	 	 			accountObj.RecordTypeId = recordtypeRef.Id;  	 				       	 		
	 	 			List<String> nameofuser = String.valueOf(likeByUserMap.get(sKey)).split(' ');  	 	 		
	 	 			accountObj.LastName__c = '';
	 	 			for(Integer s = 0; s < nameofuser.size(); s++){          	 					         	 					
	 	 				if(accountObj.FirstName__c == null){
	 	 					accountObj.FirstName__c = nameofuser[s];
	 	 			   	}else{ 	 		         	 			
	 	 					accountObj.LastName__c = accountObj.LastName__c + ' ' + nameofuser[s];
	 	 			   	}
	 	 			}
	 	 			accountforFbusersList.add(accountObj); 
	   			}
	   		}
	   		//insert accountforFbusersList;
	   		database.insert(accountforFbusersList,false);
	        if(accountforFbusersList.size() > 0){
	        	for(Account acc : accountforFbusersList){
	        		personAccountMap.put(acc.FacebookID__c,acc);
	        	}
	        }
	        
	        for(Facebook_Feeds__c child : tempFeedYetToUpdateList){ // updating those feed whose account was not created, and after creation, we are updating the Posted By Informations of the feed records
				if((child.Link_to_Contact_Record__c == null)  && (personAccountMap.size() > 0) && (personAccountMap.containsKey(child.External_ID2__c))){       		
	         		child.Link_to_Contact_Record__c = personAccountMap.get(child.External_ID2__c).Id;
	           		child.Full_Name__c = personAccountMap.get(child.External_ID2__c).FirstName__c + ' '+personAccountMap.get(child.External_ID2__c).LastName__c;
	         	 	child.Username__c = personAccountMap.get(child.External_ID2__c).FBUserName__c;
	         	 	child.Profile_Link__c = 'http://www.facebook.com/'+personAccountMap.get(child.External_ID2__c).FBUserName__c;
	           					
	           		if(personAccountMap.get(child.External_ID2__c).PersonEmail__c != null){
	         	 		child.Email_Address__c = personAccountMap.get(child.External_ID2__c).PersonEmail__c;
	         	 	}
	         	 				
	         	 	if(personAccountMap.get(child.External_ID2__c).Birthday__c != null){
	         	 		child.Age__c = System.today().year() - personAccountMap.get(child.External_ID2__c).Birthday__c.year();  //calculating the age from birthday
	         	 	}        		
	         	}
	           				
	           	if(child.Facebook_User__c == null){
	           		if(fbUserRef.User_ID__c == child.External_ID2__c){ //will only satisfy is the user who is using this application comments, then his/her look up will be populated
		        		child.Facebook_User__c = fbUserRef.Id;
		        	}
	           	}  
	        }
	        
	       List<Facebook_Feeds__c> allFeedObjList = new List<Facebook_Feeds__c>();
	       allFeedObjList.addAll(tempFeedYetToUpdateList);
	       allFeedObjList.addAll(tempFeedUpdatedList); 
	              
	       List<Facebook_Feeds__c> upsertFeedList = new List<Facebook_Feeds__c>();
	       List<Facebook_Feeds__c> upsertOutboundFeedList = new List<Facebook_Feeds__c>();
	       
	       if(allFeedObjList.size() > 0){       		
	       		List<Facebook_Feeds__c> outboundChildRecordsList = new List<Facebook_Feeds__c>();
	       		outboundChildRecordsList = [select Link__c,Id,External_ID__c,Photo__c,Profile_Link__c,External_ID2__c,Username__c,RecordTypeId from Facebook_Feeds__c where RecordType.Name = 'Outbound' AND External_ID__c IN : childExtIds];
	       		Set<String> idSet = new Set<String>();
	       		Map<String,Facebook_Feeds__c> outboundFeedMap = new Map<String,Facebook_Feeds__c>(); // updated by Rohit - 10-09-2012
	       		
	       		if(outboundChildRecordsList.size() > 0){
	       			for(Facebook_Feeds__c child : outboundChildRecordsList){	   
	       				outboundFeedMap.put(child.External_ID__c,child);    				
	       				idSet.add(child.External_ID__c);       				
	       			}
	       			
	       			for(Facebook_Feeds__c child : allFeedObjList){
	       				if(!idSet.contains(child.External_ID__c)){
	       					upsertFeedList.add(child);
	       				}else{
	       					if(outboundFeedMap.containsKey(child.External_ID__c)){
	       						system.debug('child  >>>>>>>>>>>>>  '+child);
	       						child.Link__c = outboundFeedMap.get(child.External_ID__c).Link__c; // updated by Rohit - 10-09-2012
	       						child.RecordTypeId = rtOutbound;
	       						upsertOutboundFeedList.add(child);
	       						
	       					}
	       				}
	       			}
	       		}
	       		
	       		if(upsertFeedList.size() >0){	       			
	       		 	upsert upsertFeedList External_ID__c;  
	       		 	if(upsertOutboundFeedList.size() > 0){
	       		 		system.debug('outboundChildRecordsList >>>>> ' +outboundChildRecordsList);
	       		 		system.debug('upsertOutboundFeedList >>>>> ' +upsertOutboundFeedList);
	       		 		upsert upsertOutboundFeedList External_ID__c;
	       		 	} 		       		
	       		}else{
	       			upsert allFeedObjList External_ID__c;
	       		}      		
	       } 
	        
	       List<Facebook_Feeds__c> feedQueryList = new List<Facebook_Feeds__c>(); 
	       List<Facebook_Feeds__c> feedToDelete = new List<Facebook_Feeds__c>();
	       
	       if(postToDelete.size() > 0){
	       		feedQueryList = [select Id,External_ID__c from Facebook_Feeds__c where Facebook_Page__c =: null AND External_ID__c NOT IN : postToDelete];
	       		
	       		if(feedQueryList.size() > 0){
	       			for(Facebook_Feeds__c chl : feedQueryList){
	       				if(chl.External_ID__c != null){
	       					chl.IsDeleted__c = true;
	       					feedToDelete.add(chl);
	       				}
	       			}
	       		}
	       } 
	       
	       if(feedToDelete.size() > 0){
	       		update feedToDelete;
	       } 
    	
    	}catch(Exception e){
    		system.debug('****Exception *****' + e.getmessage());
          	return null;
    	}
        PageReference pr = new PageReference('/' +userRetId);
        pr.setRedirect(true);
        return pr;
    }
}
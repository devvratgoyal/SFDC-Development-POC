/*
Company : Fujitsu America
Date : August 6,2012
Author : Rohit Sen
Description : This class is used for fetching the likes,comments,comment likes for a particular messages 
              relative to a Page. Objects updated is Facebook Child Feeds. This class is invoked when any Feed Object is 
              inserted or being updated. It Implements Email Handler, thus negeting the HTTP Request limit of Salesforce. 
History :
*/ 




global class GetFacebookFeeds_Comments_Likes implements Messaging.InboundEmailHandler 
{   
    //Variable Declaration
    public Facebook_Feeds__c fbFeedRef; 
    public Facebook_User__c fbUserRef;
    public Facebook_Child_Feed__c fbChildFeedObj;
    public List<Facebook_Child_Feed__c> fbChildFeedObjectInsertList;
    public List<Facebook_Child_Feed__c> childList;
    public List<Account> accountList;   
    public Account accountObj;
    public RecordType recordtypeRef;
    public String userName;
    public String userId;
    public String commentId;
    public String postId;
    public String likeCount;
    public String comment;
    public Map<String,String> commentDataMap;
    public List<Account> newAccountToCreateList;
    public Map<String,Account> personAccountMap;

    public Facebook_Child_Feed__c childFeedObj;
    public List<Facebook_Child_Feed__c> childFeedObjectInsertList;
    public Facebook_Child_Feed__c childObjRef;
    //End Of Variable Declaration
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult(); 
        Set<String> commentIdstodelete = new Set<String>();
        List<Facebook_Child_Feed__c> childQueryList1 = new List<Facebook_Child_Feed__c>();
        List<Facebook_Child_Feed__c> childQueryList = new List<Facebook_Child_Feed__c>();
        Set<String> childPostLikeExtIdList = new Set<String>();
        
        try
        {
           String strServiceCall = email.subject.trim();  //Service Name
           String strBody = email.plainTextBody;  // PostId
            
           system.debug('Call Services >>>>>>>>>>>>>>>> ' + strServiceCall + ' <<<<<<<<<< PostId >>>>>>>>>>>>>>>' +strBody );
             
           if(strServiceCall.contains('Sandbox:'))
           {
               strServiceCall = strServiceCall.Replace('Sandbox:','').trim();
           }
            
           strServiceCall = strServiceCall.trim();
            
           if(strBody.contains('Sandbox:'))
           {
               strBody = strBody.Replace('Sandbox:','').trim();
           }
            
           strBody = strBody.trim();
                   
           System.debug('Post Id >>>>>>>>>>>>>>> :' + strBody );     
           
           system.debug('strServiceCall >>>>>>>>>>>>>>>>'+strServiceCall);
           
           recordtypeRef = [select Id from RecordType where RecordType.Name =: 'Person Account' limit 1];    
           
           if(strServiceCall == 'UpdateFacebookChildObject')
           {
                Object comment,likes;
                List<Object> commentLikeDataList = new List<Object>(); //retrieves all information from dataMap with Key - "comments"
                Map<String,Object> tempLikeCommentMap = new Map<String,Object>();  
                List<Object> tempList = new List<Object>();           
                fbChildFeedObjectInsertList = new List<Facebook_Child_Feed__c>();
                accountList = new List<Account>();
                commentDataMap = new Map<String,String>();
                newAccountToCreateList = new List<Account>();        
                List<Object> likeDataList = new List<Object>();
                Map<String,Object> likedataMap = new Map<String,Object>();
                personAccountMap = new Map<String,Account>();  //contains all details of person accounts                
                    
                fbFeedRef = [select Id,External_ID__c,External_ID2__c,Facebook_Page__c,Facebook_Page__r.Name,Facebook_Page__r.Facebook_ID__c,Facebook_Page__r.Facebook_User__c from Facebook_Feeds__c where External_ID__c =: strBody];  // retrieving details from Feed object when External ID [Page Id] is equal to pageId passed in the email service
                
                if(fbFeedRef.Facebook_Page__c != null) //modified by rohit Dt: 08-09-2012
                {
                    fbUserRef = [select Name,Id,Access_Token__c,User_ID__c from Facebook_User__c where Id =: fbFeedRef.Facebook_Page__r.Facebook_User__c];
                }
                else
                {
                    fbUserRef = [select Name,Id,Access_Token__c,User_ID__c from Facebook_User__c where User_ID__c =: fbFeedRef.External_ID2__c];
                }
                            
                String FeedCommentLikeURL = 'https://graph.facebook.com/'+strBody+'?fields=comments,likes&limit=1000&access_token='+fbUserRef.Access_Token__c;     
                Http h2 = new Http();
                HttpRequest hreq2 = new HttpRequest();
                hreq2.setEndpoint(FeedCommentLikeURL);
                hreq2.setMethod('GET');
                HttpResponse hres2 = h2.send(hreq2);
                String resp2 = hres2.getBody(); 
                
                Map<String, Object> commentLikeDataMap = (Map<String, Object>)JSON.deserializeUntyped(resp2); // deserializing the JSON Response from facebook.    
                
                if(commentLikeDataMap != null)
                {
                    Map<String, Object> commentLikeDataMaptemp = (Map<String, Object>)commentLikeDataMap.get('comments');
                    system.debug(commentLikeDataMaptemp.keySet()+'commentLikeDataMaptemp >>>>>>>>>>>>>'+commentLikeDataMaptemp);
                
                if(Integer.valueOf(commentLikeDataMaptemp.get('count')) > 0) //if it contains the key "comments"
                {
                    commentLikeDataList.add(commentLikeDataMap.get('comments'));  // retrieving the value part from the key "comments" and storing it in the list
                                        
                    for(Integer i = 0; i < commentLikeDataList.size(); i++)
                    {
                        tempLikeCommentMap = (Map<String,Object>)commentLikeDataList[i];  //converting the list to a map. Since, always a single instance will be present, so we are directly using the index 0
                        
                    }
                    
                    if(Integer.valueOf(tempLikeCommentMap.get('count')) > 0)
                    {
                        
                        tempList.add(tempLikeCommentMap.get('data'));                   
                        system.debug(tempList.size()+'  tempList>>>>>>>>>>>>>>>> '+tempList);
                        for(Integer i = 0; i < tempList.size(); i++)
                        {                               
                            comment = (((Map<String,Object>)commentLikeDataList[i]).get('data'));  //retreiving the values of key = "data" and converting it into object
                            system.debug(comment +'  comment >>>>>>>>>>>>>>>> ');                 
                        }
                        
                        String newJSON2 = JSON.serialize(comment);      //serializing object x. This JSON contains all the comment data relative to a message           
                        
                        JSONParser parser = JSON.createParser(newJSON2); // creating a JSON Parser object on the JSON..
                        Integer count1 = 0,count2 = 0;  //these variable are needed to restrict value of "likes" from getting updated to other records whose like count = 0
                        
                        while(parser.nextToken() != null)  //will iterate until the token is null..
                        {           
                            //system.debug(parser.getText()+'\n Rohit Test 1 ....'+parser.nextToken());                                    
                            Boolean flag = false;
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
                            {
                                String fieldName = parser.getText();  
                                //system.debug(parser.getText()+'\n Rohit Test 2 ....'+parser.nextToken());                          
                                parser.nextToken();
                                        
                                if(fieldName == 'created_time')
                                {        
                                	//system.debug(parser.getText()+'\n Rohit Test 3 ....'+parser.nextToken());                               
                                }
                                 if(fieldName == 'from') //comment posted by
                                {  
                                    //system.debug(parser.getText()+'\n Rohit Test 4 ....'+parser.nextToken());                            
                                    if(parser.getCurrentToken() == JSONToken.START_OBJECT)  // this check is done because of from : {name = abc , id = 123} [This is an object and ]
                                    {
                                    	//system.debug(parser.getText()+'\n Rohit Test 5 ....'+parser.nextToken());
                                        while(parser.nextToken() != null  && parser.getCurrentToken() != JSONToken.END_OBJECT)
                                        {                                        	
                                        	//system.debug(parser.getText()+'\n Rohit Test 6 ....'+parser.nextToken());
                                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
                                            {
                                                String fieldNametemp = parser.getText();                                                
                                                //system.debug(parser.getText()+'\n Rohit Test 7 ....'+parser.nextToken());
                                                if(fieldNametemp == 'name')  //comments posted by name
                                                {
                                                	//system.debug(parser.getText()+'\n Rohit Test 8 ....'+parser.nextToken());
                                                    parser.nextToken();
                                                    userName = parser.getText();
                                                    system.debug('userName >>>>>>>>>>'+userName);
                                                    if(userName == fbFeedRef.Facebook_Page__r.Name)
                                                    {
                                                        system.debug(fbUserRef.Name+'  userName inside if >>>>>>>>>>'+userName);
                                                        userName = fbUserRef.Name;
                                                    }
                                                    
                                                    
                                                }
                                                else if(fieldNametemp == 'category')
                                                {
                                                	//system.debug(parser.getText()+'\n Rohit Test 9 ....'+parser.nextToken());
                                                    parser.nextToken();
                                                }
                                                else if(fieldNametemp == 'id')  // comments posted by Id
                                                {
                                                	//system.debug(parser.getText()+'\n Rohit Test 10 ....'+parser.nextToken());
                                                    parser.nextToken();
                                                    userId = parser.getText();
                                                    system.debug(userId+'  userId');
                                                        
                                                    if(userId == fbFeedRef.Facebook_Page__r.Facebook_ID__c)
                                                    {
                                                        system.debug(fbUserRef.User_ID__c+'  userId inside if >>>>>>>>>>'+userId);
                                                                                                             
                                                        userId = fbUserRef.User_ID__c ;
                                                    }                                                    
                                                    system.debug(userId+'   .......... userId >>>>>>>>> userName >>>>>>>>>  '+userName);
                                                    commentDataMap.put(userId,userName); // map contains all userId and userName [key - userId, value - userName]
                                                                                        
                                                }
                                                else
                                                {
                                                    break;                                                      
                                                }
                                            }                                       
                                    
                                        }                                       
                                    continue;                                           
                                    }                                       
                                } 
                                 if(fieldName == 'likes') //comment like count
                                {
                                	
                                    count1++;
                                    likeCount = parser.getText();
                                    system.debug(likeCount+'\n Rohit Test 11 ....');
                                
                                }
                                                            
                                 if(fieldName == 'id') //comment Id
                                {
                                	//system.debug(parser.getText()+'\n Rohit Test 12 ....'+parser.nextToken());
                                    commentId = parser.getText();   
                                    flag = true;
                                    system.debug('\n commentId inside fieldName=commentId >>>>> '+commentId);                    
                                                                
                                }
                                 if(fieldName == 'message' ) //comment
                                {                                	
                            		//system.debug(parser.getText()+'\n Rohit Test 13 ....'+parser.nextToken());
                                    comment = parser.getText();
                                	system.debug('\n ***** flag =  '+flag+'\n comment >>>>>>>>>> '+comment);
                                	if(flag == false)
                                	{
                                		parser.nextToken();
                                		String fname = parser.getText();
                                		system.debug('\n fname >>>> '+fname);
                                		if(fname == 'id')
                                		{
                                			system.debug('\n parser.nextToken() >>>>>> '+parser.nextToken());
                                			//parser.nextToken(); // uncomment if needed
                                			commentId = parser.getText();
                                			system.debug('\n commentId in if else ----- '+commentId);
                                		}
                                	}
                                	system.debug('\n commentId in message >>>>>>>  '+commentId);
                                	fbChildFeedObj = new Facebook_Child_Feed__c();  // creating Child Feed Object
                                    Schema.DescribeFieldResult fieldResult = Facebook_Child_Feed__c.Feed_Type__c.getDescribe(); // used to get the values of the picklist
                                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                            
                                    for(Schema.PicklistEntry p : ple)
                                    {   
                                        if((p.getLabel() =='Comment') && p.isActive() == true)
                                        {   
                                            fbChildFeedObj.Feed_Type__c = p.getValue();
                                        }
                                    }
                                    
                                    fbChildFeedObj.External_ID2__c = userId;  // External_ID2__c contains the user Facebook Id that have posted the comment
                                    fbChildFeedObj.Message__c = String.valueOf(comment);
                                    fbChildFeedObj.External_ID__c = commentId;
                                    
                                    
                                    fbChildFeedObj.FBUserId_FeedId_External_Id__c = commentId + '|' + strBody;  //external ID field [value = fbUserId | Feed Id]
                                    system.debug('\n  fbChildFeedObj.FBUserId_FeedId_External_Id__c >>>>>>>>>>  '+fbChildFeedObj.FBUserId_FeedId_External_Id__c);                                    
                                    if(likeCount != null && count1 != count2)
                                    {
                                        fbChildFeedObj.Likes__c = Integer.valueOf(likeCount);
                                        count2 = count1;
                                    }                                   
                                    else
                                    {
                                        fbChildFeedObj.Likes__c = null;
                                    }
                                    system.debug('\n commentId before link insert >>> '+commentId);
                                    fbChildFeedObj.Link__c = 'http://www.facebook.com/'+commentId;
                                    fbChildFeedObj.Facebook_Feed__c = fbFeedRef.Id;
                                    fbChildFeedObj.Facebook_Page__c = fbFeedRef.Facebook_Page__c;
                                    
                                    if(fbUserRef.User_ID__c == userId) //will only satisfy is the user who is using this application comments, then his/her look up will be populated
                                    {
                                        fbChildFeedObj.Facebook_User__c = fbUserRef.Id;
                                    }
                                    else
                                    {
                                        fbChildFeedObj.Facebook_User__c = null;
                                    }
                            		System.debug(fbChildFeedObj+'****************fbChildFeedObj');
                                    fbChildFeedObjectInsertList.add(fbChildFeedObj);  //adding each object in the List that will be used for insertion  
                                    commentIdstodelete.add(commentId);  //new added by rohit. used for deletion of comments
                                }  
                    
                            }    
                     
                        } // end of outer While loop
                        
                        accountList = [select Id,RecordTypeId,FacebookID__c,Name,FBUserName__c,PersonEmail__c,Birthday__c from Account where RecordType.Name =: 'Person Account' AND FacebookID__c IN : commentDataMap.keySet()];
                                                
                        if(accountList.size() > 0)
                        {
                            for(Account acc : accountList)
                            {
                                personAccountMap.put(acc.FacebookID__c,acc);  //map contains all person account objects relative to its key [Facebook ID]
                            }
                        }
                        
                        for(Facebook_Child_Feed__c child : fbChildFeedObjectInsertList)
                        {   
                            //if(personAccountMap.containsKey(child.External_ID2__c) && (!nonduplicateids.contains(child.External_ID2__c)))
                        
                            if(personAccountMap.containsKey(child.External_ID2__c))
                            {
                                child.Link_to_Contact_Record__c = personAccountMap.get(child.External_ID2__c).Id;
                                child.Full_Name__c = personAccountMap.get(child.External_ID2__c).Name;
                                child.Username__c = personAccountMap.get(child.External_ID2__c).FBUserName__c;
                                child.Profile_Link__c = 'http://www.facebook.com/'+personAccountMap.get(child.External_ID2__c).FBUserName__c;
                                if(personAccountMap.get(child.External_ID2__c).PersonEmail__c != null)
                                {
                                    child.Email_Address__c = personAccountMap.get(child.External_ID2__c).PersonEmail__c;
                                }
                                if(personAccountMap.get(child.External_ID2__c).Birthday__c != null)
                                {
                                    child.Age__c = System.today().year() - personAccountMap.get(child.External_ID2__c).Birthday__c.year();  //calculating the age from birthday
                                }
                
                    
                            }
                            //else if(!nonduplicateids.contains(child.External_ID2__c)) //will execute when new facebook user has commented and is currently not a person account. In that case, create new person accounts
                            else
                            {
                                
                                accountObj = new Account();
                                accountObj.Access_Token__c = fbUserRef.Access_Token__c;
                                accountObj.FacebookID__c = child.External_ID2__c;
                                accountObj.RecordTypeId = recordtypeRef.Id;
                                system.debug('testing name of user >>>>>>>>>>>>> '+String.valueOf(commentDataMap.get(child.External_ID2__c)));                  
                                List<String> nameofuser = String.valueOf(commentDataMap.get(child.External_ID2__c)).split(' '); 
                                accountObj.LastName__c = '';
                                for(Integer s = 0; s < nameofuser.size(); s++)
                                {                                                               
                                    if(accountObj.FirstName__c == null)
                                    {
                                        accountObj.FirstName__c = nameofuser[s];
                                    }
                                    else 
                                    {                                   
                                        accountObj.LastName__c = accountObj.LastName__c + ' ' + nameofuser[s];
                                    }
                                
                                }
                                newAccountToCreateList.add(accountObj);                     
                
                            }
                
           
                        }
                        
                        system.debug(newAccountToCreateList.size()+'     newAccountToCreateList >>>>>>>>>>>>>>>>> '+newAccountToCreateList);
                        insert newAccountToCreateList;
                        //database.insert(newAccountToCreateList,false);
                        if(newAccountToCreateList.size() > 0)
                        {
                            for(Account accnt : newAccountToCreateList) // updating the personAccntMap with the new accounts created
                            {
                                personAccountMap.put(accnt.FacebookID__c,accnt);  //map contains all person account objects relative to its key [Facebook ID]
                            }
                        }
                        
                    } //end of 2nd inner if
                    
                } // end of 1st inner if
                
                
                /******************* Saving the details on Facebook Child Feed Object for Post Likes [ Feed Type will be "Post Like" for such records ] **************************/
              
                Map<String,String> likeUserDetailsMap = new Map<String,String>();
        
                if(commentLikeDataMap.containsKey('likes'))
                {
                    likeDataList.add(commentLikeDataMap.get('likes'));
                    
                    for(Integer i = 0; i < likeDataList.size();i++)
                    {
                        likedataMap = (Map<String,Object>)likeDataList[i];
                    }
                    
                    if(likedataMap.get('count') != 0)  // if value of key(count) != 0 , means, there are likes present
                    {
            
                        String likeByUserName,likeByUserId;
              
                        likes = (Object)likedataMap.get('data'); 
              
                        String newJSON1 = JSON.serialize(likes);       //serializing object x. This JSON contains all the comment data relative to a message        
            
                        JSONParser likeparser = JSON.createParser(newJSON1); // creating a JSON Parser object on the JSON..
              
                        while(likeparser.nextToken() != null)
                        {
                            if ((likeparser.getCurrentToken() == JSONToken.FIELD_NAME))
                            {
                                String likefieldName = likeparser.getText();                            
                                likeparser.nextToken();
                                                
                                if(likefieldName == 'name')
                                {
                                    likeByUserName = likeparser.getText();    
                                    if(likeByUserName == fbFeedRef.Facebook_Page__r.Name)
                                    {
                                        likeByUserName = fbUserRef.Name;
                                    }                          
                                }
                                else if(likefieldName == 'category')
                                {
                                     //likeparser.nextToken();
                                }
                                else if(likefieldName == 'id')
                                {
                                    likeByUserId = likeparser.getText();
                                    if(likeByUserId == fbFeedRef.Facebook_Page__r.Facebook_ID__c)
                                    {
                                        likeByUserId = fbUserRef.User_ID__c ;
                                    }                                                    
                                    system.debug(likeByUserId +'   .......... likeByUserId >>>>>>>>> likeByUserName >>>>>>>>>  '+likeByUserName);
                                                     
                    
                                    likeUserDetailsMap.put(likeByUserId,likeByUserName);
                    
                                    fbChildFeedObj = new Facebook_Child_Feed__c();  // creating Child Feed Object
                                    Schema.DescribeFieldResult fieldResult = Facebook_Child_Feed__c.Feed_Type__c.getDescribe(); // used to get the values of the picklist
                                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                            
                                    for(Schema.PicklistEntry p : ple)
                                    {   
                                        if((p.getLabel() == 'Post Like') && p.isActive() == true)
                                        {   
                                            fbChildFeedObj.Feed_Type__c = p.getValue();
                                        }
                                    }
                                
                                    fbChildFeedObj.External_ID2__c = likeByUserId;  // External_ID2__c contains the user Facebook Id that have posted the comment
                                    fbChildFeedObj.Facebook_Feed__c = fbFeedRef.Id;
                                    fbChildFeedObj.Facebook_Page__c = fbFeedRef.Facebook_Page__c;
                                    fbChildFeedObj.FBUserId_FeedId_External_Id__c = 'LikeId = ' + likeByUserId + '|' + strBody;  // external Id for Child Feed type = Like
                                    childPostLikeExtIdList.add('LikeId = ' + likeByUserId + '|' + strBody);
                                    fbChildFeedObj.IsDeleted__c = false;
                                    
                                    if(fbUserRef.User_ID__c == likeByUserId) //will only satisfy is the user who is using this application comments, then his/her look up will be populated
                                    {
                                        fbChildFeedObj.Facebook_User__c = fbUserRef.Id;
                                    }
                                    else
                                    {
                                        fbChildFeedObj.Facebook_User__c = null;
                                    }                       
                    
                                    fbChildFeedObjectInsertList.add(fbChildFeedObj);   
                                }
                            
                            }
             
                        } 
            
                    } 
                    
                    
                    List<Account> tempAccntList = new List<Account>();
                    List<Facebook_Child_Feed__c> tempChild = new List<Facebook_Child_Feed__c>();
                    tempChild = [select External_ID2__c from Facebook_Child_Feed__c where Facebook_Page__c =: fbFeedRef.Facebook_Page__c AND Feed_Type__c =: 'Post Like' AND External_ID2__c IN: likeUserDetailsMap.keySet()];
                    Set<String> childFeedIds = new Set<String>();
         
                    if(tempChild.size() > 0)
                    {
                        for(Facebook_Child_Feed__c ch : tempChild)
                        {
                            childFeedIds.add(ch.External_ID2__c);
                        }
                    }   
       
                    if(childFeedIds.size() > 0)
                    {
                        tempAccntList = [select Id,RecordTypeId,FacebookID__c,Name,FBUserName__c,PersonEmail__c,Birthday__c from Account where RecordType.Name = 'Person Account' AND FacebookID__c IN : childFeedIds];
                    }
        
                    for(Account accnttemp : tempAccntList) // updating the personAccntMap with the new accounts created
                    {
                        personAccountMap.put(accnttemp.FacebookID__c,accnttemp);  //map contains all person account objects relative to its key [Facebook ID]
                    }         

                    for(Facebook_Child_Feed__c child : fbChildFeedObjectInsertList)
                    {
                        if((child.Link_to_Contact_Record__c == null)  && (personAccountMap.size() > 0) && (personAccountMap.containsKey(child.External_ID2__c)))
                        {               
                            child.Link_to_Contact_Record__c = personAccountMap.get(child.External_ID2__c).Id;
                            child.Full_Name__c = personAccountMap.get(child.External_ID2__c).Name;
                            child.Username__c = personAccountMap.get(child.External_ID2__c).FBUserName__c;
                            child.Profile_Link__c = 'http://www.facebook.com/'+personAccountMap.get(child.External_ID2__c).FBUserName__c;
                            
                            if(personAccountMap.get(child.External_ID2__c).PersonEmail__c != null)
                            {
                                child.Email_Address__c = personAccountMap.get(child.External_ID2__c).PersonEmail__c;
                            }
                            
                            if(personAccountMap.get(child.External_ID2__c).Birthday__c != null)
                            {
                                child.Age__c = System.today().year() - personAccountMap.get(child.External_ID2__c).Birthday__c.year();  //calculating the age from birthday
                            }               
                
                        }
                        
                        if(child.Facebook_User__c == null)
                        {
                            if(fbUserRef.User_ID__c == child.External_ID2__c) //will only satisfy is the user who is using this application comments, then his/her look up will be populated
                            {
                                child.Facebook_User__c = fbUserRef.Id;
                            }
                        }  
          
                    } 
                    
                
                } // end of if for "Facebook Child Feed Object for Post Likes"          
                
                if(fbChildFeedObjectInsertList.size() > 0)
                {
                    System.debug('fbChildFeedObjectInsertList*****'+fbChildFeedObjectInsertList);
                    upsert fbChildFeedObjectInsertList FBUserId_FeedId_External_Id__c;  //upserting facebook child feed objects 
                    //System.debug('fbChildFeedObjectInsertList*****'+fbChildFeedObjectInsertList[0].Id+'**test**'+fbChildFeedObjectInsertList[1].Id);                    
                }
                                
                List<Facebook_Child_Feed__c> childUpdateforDeleteList = new List<Facebook_Child_Feed__c>();
            
                if(commentIdstodelete.size() > 0)
                {
                    childQueryList = [select Id,External_ID__c from Facebook_Child_Feed__c where Facebook_Page__c =: fbFeedRef.Facebook_Page__c AND Feed_Type__c = 'Comment' AND External_ID__c NOT IN : commentIdstodelete AND Facebook_Feed__r.External_ID__c =: strBody];
                    if(childQueryList.size() > 0)
                    {
                        
                        for(Facebook_Child_Feed__c c : childQueryList)
                        {
                            c.IsDeleted__c = true;
                            childUpdateforDeleteList.add(c);
                        }
                    }
                }
                else
                {
                    childQueryList = [select Id,External_ID__c from Facebook_Child_Feed__c where Facebook_Page__c =: fbFeedRef.Facebook_Page__c AND Feed_Type__c = 'Comment' AND Facebook_Feed__r.External_ID__c =: strBody];
                    if(childQueryList.size() > 0)
                    {
                        
                        for(Facebook_Child_Feed__c c : childQueryList)
                        {
                            c.IsDeleted__c = true;
                            childUpdateforDeleteList.add(c);
                        }
                    }
                }
                
                if(childPostLikeExtIdList.size() > 0 || (commentLikeDataMap.containsKey('likes') == false)) // this check deals with 2 conditions when like count gets decreased to zero and when there are like count still present
                {
                    childQueryList1 = [select Id,FBUserId_FeedId_External_Id__c,Facebook_Feed__r.External_ID__c from Facebook_Child_Feed__c where Facebook_Page__c =: fbFeedRef.Facebook_Page__c AND Feed_Type__c = 'Post Like' AND FBUserId_FeedId_External_Id__c NOT IN : childPostLikeExtIdList AND Facebook_Feed__r.External_ID__c = : strBody];
                    
                    if(childQueryList1.size() > 0)
                    {
                        for(Facebook_Child_Feed__c c1 : childQueryList1)
                        {                               
                            c1.IsDeleted__c = true;
                            childUpdateforDeleteList.add(c1);
                        }
                
                    }
                }
            
                if(childUpdateforDeleteList.size() > 0)
                {                       
                    update childUpdateforDeleteList;
                }
            }
                    
           } //end of outer if [UpdateFacebookChildObject]
           
          if(strServiceCall == 'UpdateFacebookChildObjectForCommentLikes')  
          {
                Account accountRef = new Account();
                List<Account> newAccountToCreateList1 = new List<Account>();
                Map<String,Object> likeForCommentMap = new Map<String, Object>();
                Map<String,String> likePostedByUserName_Id = new Map<String,String>();
                List<Account> accountList1 = new List<Account>();
                List<Facebook_Child_Feed__c> fbChildFeedObjectInsertList1 = new List<Facebook_Child_Feed__c>();
                Map<String,Account> personAccountMap1 = new Map<String,Account>();  //contains all details of person accounts   
                Set<String> commentLikeIdSet = new Set<String>();
                 
                childObjRef = [select External_ID2__c,Id,External_ID__c,Facebook_Feed__c,Facebook_Page__r.Facebook_User__c,Facebook_Page__c,
                               Facebook_User__c,Facebook_User__r.User_ID__c,FBUserId_FeedId_External_Id__c,Feed_Type__c,
                               Link_to_Contact_Record__c,Link_to_Contact_Record__r.Access_Token__c,Facebook_Page__r.Facebook_ID__c 
                               from Facebook_Child_Feed__c where External_ID__c =: strBody AND Feed_Type__c = 'Comment'];
                        
                if(childObjRef.Facebook_Page__c != null) // modified by Rohit. Dt - 08-09-2012
                {
                    fbUserRef = [select Id,User_ID__c,Name__c from Facebook_User__c where Id =: childObjRef.Facebook_Page__r.Facebook_User__c];
                }
                else
                {
                    fbUserRef = [select Id,Access_Token__c,User_ID__c,Name__c from Facebook_User__c where User_ID__c =: childObjRef.External_ID2__c];
                    
                }
                
                
                Facebook_Pages__c userIdForPageAdminRef = new Facebook_Pages__c();
                
                if(childObjRef.Facebook_Page__c != null)
                {
                    userIdForPageAdminRef = [select Facebook_ID__c,Facebook_User__c from Facebook_Pages__c where Facebook_ID__c =: childObjRef.Facebook_Page__r.Facebook_ID__c];  ///get the Facebook user id of the Admin  of the page the comment is related to
                }
                            
                //accountRef = [select Name,FirstName__c,LastName__c from Account where RecordType.Name =: 'Person Account' AND FacebookID__c =: fbUserRef.User_ID__c]; // account detail of admin of the page
            
                String CommentLikeURL = 'https://graph.facebook.com/'+strBody+'/likes&access_token='+childObjRef.Link_to_Contact_Record__r.Access_Token__c;     
                Http h1 = new Http();
                HttpRequest hreq1 = new HttpRequest();
                hreq1.setEndpoint(CommentLikeURL);
                hreq1.setMethod('GET');
                HttpResponse hres1 = h1.send(hreq1);
                String resp1 = hres1.getBody(); 
     
                Map<String, Object> commentLikeMap = (Map<String, Object>)JSON.deserializeUntyped(resp1); // deserializing the JSON Response from facebook.    
                List<Object> commentLikeList = (List<Object>)commentLikeMap.get('data');
                
                system.debug('\n commentLikeList >>>> '+commentLikeList);
                if(commentLikeList.size() > 0)
                {
                    for(Integer i=0; i< commentLikeList.size(); i++)
                    {
                        likeForCommentMap = (Map<String, Object>)commentLikeList[i];                                    
                    
                        fbChildFeedObj = new Facebook_Child_Feed__c();  // creating Child Feed Object
                                
                        Schema.DescribeFieldResult fieldResult = Facebook_Child_Feed__c.Feed_Type__c.getDescribe(); // used to get the values of the picklist
                        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                            
                        for(Schema.PicklistEntry p : ple)
                        {   
                            if((p.getLabel() == 'Comment Like') && p.isActive() == true)
                            {   
                                fbChildFeedObj.Feed_Type__c = p.getValue();
                            }
                        }
                        
                        
                        if(userIdForPageAdminRef.Facebook_ID__c != String.valueOf(likeForCommentMap.get('id'))) //if likeById from JSON is not equal to Facebook page Id, then execute 
                        {
                            fbChildFeedObj.External_ID2__c = String.valueOf(likeForCommentMap.get('id'));  // External_ID2__c contains the user Facebook Id that have liked on the comment
                            fbChildFeedObj.FBUserId_FeedId_External_Id__c = strBody + '|' + String.valueOf(likeForCommentMap.get('id'));  //external ID field [value =  Feed Id | fbUserId]
                            likePostedByUserName_Id.put(String.valueOf(likeForCommentMap.get('id')),String.valueOf(likeForCommentMap.get('name'))); //map contains UserId and Username of facebook users liking a particular comment
                            commentLikeIdSet.add(strBody + '|' + String.valueOf(likeForCommentMap.get('id')));
                        
                        } 
                        else  //[This condition is used so as to satisfy the logic when the page admin likes a particular comment or post. In that scenario the JSON returns the Id and name of the page and not the admin]. So, if this condition satisfies, the likePostedByUserName_Id map contains the id and name of the Facebook User related to the page
                        {
                            fbChildFeedObj.External_ID2__c = fbUserRef.User_ID__c;                          
                            fbChildFeedObj.FBUserId_FeedId_External_Id__c = strBody + '|' + fbUserRef.User_ID__c;  //external ID field [value =  Feed Id | fbUserId]
                            commentLikeIdSet.add(strBody + '|' + fbUserRef.User_ID__c);
                            likePostedByUserName_Id.put(fbUserRef.User_ID__c,fbUserRef.Name__c); //map contains UserId and Username of facebook users liking a particular comment
                        }
                        fbChildFeedObj.External_ID__c = strBody;
                        fbChildFeedObj.Link__c = 'http://www.facebook.com/'+strBody;
                        fbChildFeedObj.Facebook_Feed__c = childObjRef.Facebook_Feed__c;
                        fbChildFeedObj.Facebook_Page__c = childObjRef.Facebook_Page__c;
                        fbChildFeedObj.Facebook_Comment_Likes__c = childObjRef.Id;
                        fbChildFeedObj.IsDeleted__c = false;
                        
                        if(childObjRef.Facebook_Page__r.Facebook_ID__c == String.valueOf(likeForCommentMap.get('id'))) // if likeById == PageId then set childObj's Facebook user to creator of the page
                        {
                            
                            fbChildFeedObj.Facebook_User__c = userIdForPageAdminRef.Facebook_User__c;
                        }
                        
                        else if((childObjRef.Facebook_User__c != null) && (fbUserRef.User_ID__c == String.valueOf(likeForCommentMap.get('id')))) //will only satisfy is the user who is using this application comments, then his/her look up will be populated
                        {
                            
                            fbChildFeedObj.Facebook_User__c = fbUserRef.Id;
                        }
                        else
                        {
                            
                            fbChildFeedObj.Facebook_User__c = null;
                        }
                        fbChildFeedObj.isInserted__c = true;
                        fbChildFeedObjectInsertList1.add(fbChildFeedObj);  //adding each object in the List that will be used for insertion 
                    
                    }
                            
                    accountList1 = [select Id,RecordTypeId,FacebookID__c,Name,FBUserName__c,PersonEmail__c,Birthday__c from Account where RecordType.Name =: 'Person Account' AND FacebookID__c IN : likePostedByUserName_Id.keySet()];
                
                
                    
                    if(accountList1.size() > 0)
                    {
                        
                        for(Account acc : accountList1)
                        {
                            personAccountMap1.put(acc.FacebookID__c,acc);  //map contains all person account objects relative to its key [Facebook ID]
                        }
                        //Set<string> nonduplicateids=new Set<string>();
                        for(Facebook_Child_Feed__c child : fbChildFeedObjectInsertList1)
                        {
                            //if(personAccountMap1.containsKey(child.External_ID2__c) && (!nonduplicateids.contains(child.External_ID2__c)))
                                if(personAccountMap1.containsKey(child.External_ID2__c))
                                {
                                    
                                    child.Link_to_Contact_Record__c = personAccountMap1.get(child.External_ID2__c).Id;
                                    child.Full_Name__c = personAccountMap1.get(child.External_ID2__c).Name;
                                    child.Username__c = personAccountMap1.get(child.External_ID2__c).FBUserName__c;
                                    child.Profile_Link__c = 'http://www.facebook.com/'+personAccountMap1.get(child.External_ID2__c).FBUserName__c;
                                    if(personAccountMap1.get(child.External_ID2__c).PersonEmail__c != null)
                                    {
                                        child.Email_Address__c = personAccountMap1.get(child.External_ID2__c).PersonEmail__c;
                                    }
                                    if(personAccountMap1.get(child.External_ID2__c).Birthday__c != null)
                                    {
                                        child.Age__c = System.today().year() - personAccountMap1.get(child.External_ID2__c).Birthday__c.year();  //calculating the age from birthday
                                    }
                    
                        
                                }
                                //else if(!nonduplicateids.contains(child.External_ID2__c))//will execute when new facebook user has commented and is currently not a person account. In that case, create new person accounts
                                else
                                {
                                    
                                    accountObj = new Account();
                                    accountObj.Access_Token__c = childObjRef.Link_to_Contact_Record__r.Access_Token__c;
                                    accountObj.FacebookID__c = child.External_ID2__c;
                                    accountObj.RecordTypeId = recordtypeRef.Id;  
                                    List<String> nameofuser = String.valueOf(likePostedByUserName_Id.get(child.External_ID2__c)).split(' ');                                    
                                    accountObj.LastName__c = '';
                                    for(Integer s = 0; s < nameofuser.size(); s++)
                                    {    
                                        if(accountObj.FirstName__c != null)
                                        {
                                            accountObj.FirstName__c = nameofuser[s];
                                        }                                   
                                        accountObj.LastName__c = accountObj.LastName__c + ' ' + nameofuser[s];
                                    }
                                    newAccountToCreateList1.add(accountObj);                    
                    
                                }
                    
                            }
                        }
                        system.debug(newAccountToCreateList1.size()+'     newAccountToCreateList1 >>>>>>>>>>>>>>>>> '+newAccountToCreateList1);
                        insert newAccountToCreateList1;
                        //database.insert(newAccountToCreateList1,false);
                        if(newAccountToCreateList1.size() > 0)
                        {
                            
                            for(Account accnt : newAccountToCreateList1) // updating the personAccntMap with the new accounts created
                            {
                                personAccountMap1.put(accnt.FacebookID__c,accnt);  //map contains all person account objects relative to its key [Facebook ID]
                            }
                        }
                        
                        for(Facebook_Child_Feed__c child : fbChildFeedObjectInsertList1)
                        {
                            
                            if((child.Link_to_Contact_Record__c == null)  && personAccountMap1.size() > 0 && personAccountMap1.containsKey(child.External_ID2__c))
                            {      
                                    
                                child.Link_to_Contact_Record__c = personAccountMap1.get(child.External_ID2__c).Id;
                                child.Full_Name__c = personAccountMap1.get(child.External_ID2__c).Name;
                                child.Username__c = personAccountMap1.get(child.External_ID2__c).FBUserName__c;
                                child.Profile_Link__c = 'http://www.facebook.com/'+personAccountMap1.get(child.External_ID2__c).FBUserName__c;
                                if(personAccountMap1.get(child.External_ID2__c).PersonEmail__c != null)
                                {
                                    child.Email_Address__c = personAccountMap1.get(child.External_ID2__c).PersonEmail__c;
                                }
                                if(personAccountMap1.get(child.External_ID2__c).Birthday__c != null)
                                {
                                    child.Age__c = System.today().year() - personAccountMap1.get(child.External_ID2__c).Birthday__c.year();  //calculating the age from birthday
                                }               
                    
                            }                   
              
                        } 
                    
                }
                
                
                if(fbChildFeedObjectInsertList1.size() > 0)
                {
                    upsert fbChildFeedObjectInsertList1 FBUserId_FeedId_External_Id__c;  //upserting facebook child feed objects
                    
                }
                
                
                List<Facebook_Child_Feed__c> childUpdateforDeleteList = new List<Facebook_Child_Feed__c>();
                
                
                if(commentLikeIdSet.size() > 0)
                {
                    
                    List<Facebook_Child_Feed__c> childQueryList2 = new List<Facebook_Child_Feed__c>();
                    childQueryList2 = [select Id,FBUserId_FeedId_External_Id__c from Facebook_Child_Feed__c where Facebook_Page__c =: childObjRef.Facebook_Page__c AND Feed_Type__c = 'Comment Like' AND FBUserId_FeedId_External_Id__c NOT IN : commentLikeIdSet AND External_ID__c = : strBody];
                    
                    if(childQueryList2.size() > 0)
                    {
                          
                        for(Facebook_Child_Feed__c c : childQueryList2)
                        {
                            c.IsDeleted__c = true;                          
                            childUpdateforDeleteList.add(c);
                        }
                    }
                }
                else
                {
                    List<Facebook_Child_Feed__c> childQueryList2 = new List<Facebook_Child_Feed__c>();
                    childQueryList2 = [select Id,FBUserId_FeedId_External_Id__c from Facebook_Child_Feed__c where Facebook_Page__c =: childObjRef.Facebook_Page__c AND Feed_Type__c = 'Comment Like' AND External_ID__c = : strBody];
                    if(childQueryList2.size() > 0)
                    {                          
                        for(Facebook_Child_Feed__c c : childQueryList2)
                        {
                            c.IsDeleted__c = true;                          
                            childUpdateforDeleteList.add(c);
                        }
                    }
                
                }               
                if(childUpdateforDeleteList.size() > 0)
                {
                    update childUpdateforDeleteList;
                }
         
            }
           
        }//end of try
        catch(exception e)
        {           
            system.debug('****Exception *****' + e.getmessage());
            return null;
        }
        return result;
        
    }// end of constructor
}// end of main class
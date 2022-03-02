/*
Company : Fujitsu America
Date : August 7,2012
Author : Ankit khurana
Description : This class is used for saving detail of the facebook users into the Account object. The class uses inbound emailservice 
              which is invoked by workflow rule made on the first name of user during account creation..This emailservice is further used to call Facebook service to reterive users' detail.
History 
*/ 


global class Serviceslistener implements Messaging.InboundEmailHandler 
{

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
        
            
        
        //set<String> setAccountId=new set<String>();
        String AccountId;
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try{
          
            string strServiceCall=email.subject.trim();
            string strBody = email.plainTextBody;
            system.debug('@@@@ Call Services' + strServiceCall + '@@@' +strBody );
            if(strServiceCall.contains('Sandbox:'))
            {
                strServiceCall = strServiceCall.Replace('Sandbox:','').trim();
            }
            strServiceCall=strServiceCall.trim();
            if(strBody.contains('Sandbox:'))
            {
                strBody = strBody.Replace('Sandbox:','').trim();
            }
            strBody=strBody.trim(); 
            AccountId=strBody;
            system.debug('@@@@ Call Services - Sales Order Id :' + strBody );
            System.debug('###'+ strBody );
        
            
            //retrieves user information from facebook Graph API..
           //accountObjectList
            Account  accountObject= [select Id,Birthday__c,PersonEmail__c,FacebookID__c,Gender__c,FBUserName__c,Access_Token__c from Account where RecordType.Name =: 'Person Account' and Id = : AccountId Limit 1];
           
           
           if(accountObject!=null)
           {
                    String userURL = 'https://graph.facebook.com/'+accountObject.FacebookID__c+'?access_token='+accountObject.Access_Token__c;
                    System.debug('AAAAAA'+ userURL );
                    Http h1 = new Http();
                    HttpRequest hreq1 = new HttpRequest();
                    hreq1.setEndpoint(userURL);
                    hreq1.setMethod('GET');
                    HttpResponse hres1 = h1.send(hreq1);
                    String resp1 = hres1.getBody();
                    System.debug('TTTTTTTT--->' +resp1 );
                    
                    if(resp1!=null && resp1.trim()!=''){
                        
                     userDetails u = (userDetails)Json.deserialize(resp1,Serviceslistener.userDetails.class);
                     System.debug('The User Details--->' + u.userName + '&&&' + u.birthday);
              
                    accountObject.Gender__c = u.gender;
                    accountObject.FBUserName__c = u.userName;
                    if( u.email!=null)
                    {
                    accountObject.PersonEmail__c = u.email;
                    }
                    if (u.birthday!=null)
                    {
                    accountObject.Birthday__c =Date.parse(u.birthday);
                    }
                    
                    update accountObject;
                    System.debug(accountObject+'*******accountObject');
                    
                    Account accobject=[select FacebookID__c from Account where id=:AccountId];
                    
                    List<Facebook_Feeds__c> facebookfeedList =[select Name,Profile_Link__c,Username__c,Link__c,External_ID2__c,Facebook_User__c,Email_Address__c,Age__c from Facebook_Feeds__c where External_ID2__c  =: accobject.FacebookID__c];
                        
                   System.debug(facebookfeedList+'*******facebookfeedList');
              
              
              if(facebookfeedList.size() > 0)
                {
                       for (Facebook_Feeds__c f:facebookfeedList)
                       {
                             if(accountObject.PersonEmail__c!=null)
                            {
                            f.Email_Address__c= accountObject.PersonEmail__c;
                            }
                            f.Username__c= u.name ;
                            f.External_ID2__c=accountObject.FacebookID__c;
                            f.Link__c=u.link;
                            f.Profile_Link__c=u.link;
                            
                            if(accountObject.Birthday__c!=null)
                            {
                            f.Age__c=System.today().year()-accountObject.Birthday__c.year();
                            }
                          
                    } 
            
                        update facebookfeedList;
                        System.debug(facebookfeedList+'*************facebookfeedList');
                }
                        
                    }           
           }
           if(strServiceCall == 'CallFacebookService')
            {
               system.debug('Subject' + strServiceCall + '@@@' +strBody );
            }

        }
        catch(exception e)
        {
            system.debug('****Exception *****' + e.getmessage());
            return null;
        }
   
    return result;
    }
    
        public class userDetails{
        public String userName{get;set;}
        public String gender{get;set;}
        public String email{get;set;}
        public String name{get;set;}
        public String birthday{get;set;}
        public String link{get;set;}
        
        public userDetails(string userNameTest, String genderTest,String emailTest,String birthdayTest,String nameTest, String linkTest){
            this.userName = userNameTest;
            this.gender = genderTest;
            this.email = emailTest;
            this.birthday = birthdayTest;
            this.name=nameTest;
            this.link=linkTest;
        }
       }

}
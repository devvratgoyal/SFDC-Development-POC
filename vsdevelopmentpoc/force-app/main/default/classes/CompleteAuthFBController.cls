global class CompleteAuthFBController {
	
	static webservice String updateSetting(Id fbUserid){
		FB_User__c fbuser = FB_User__c.getInstance();		
        if(fbuser.FB_Id__c != fbUserid){
        	fbuser.FB_Id__c = fbUserid;
        	update fbuser;
        	return fbuser.FB_Id__c;
        }
        return '';
	}
}
public with sharing class LinkedInAuthenticateUser {
    
    // LinkedInAuthenticateUser
    public boolean userAuthorized {get;set;}
    
    public Id serviceId {get;set;}
    public OAuthService__c oAuthService {get;set;}
    
    public LinkedIn linkedInIns {get;set;}
    private String accessToken {get;set;}
    
    // LinkedInCompleteAuthorization
    public boolean authSuccess { get; set; }
    public String message { get; set; }      
    
    public LinkedInAuthenticateUser (){
        //Query the OAuth_Token__c object to determine if we have a valid OAuth token for the user. If not, the user will first have
        //to authenticate and authorize with Foursquare.
        userAuthorized = false;
        linkedInIns = new LinkedIn(UserInfo.getUserId());
        serviceId = Apexpages.currentPage().getParameters().get('id');
        if(oAuthService == null){
        	oAuthService = [select id, Access_Token__c from OAuthService__c where id = : serviceId];
        	if(oAuthService != null && oAuthService.Access_Token__c != null && oAuthService.Access_Token__c.trim() != ''){
        		  userAuthorized = true;
        	}
        }
    }

    public PageReference userAuthorize(){
        return linkedInIns.getAuthCode(serviceId, Page.CompleteAuth_LinkedIn);
    }
    
    public PageReference completeAuthorization() {
        String authCode = Apexpages.currentPage().getParameters().get('code');
        if(authCode != null){
        	accessToken = linkedInIns.getAccessToken(serviceId, Page.CompleteAuth_LinkedIn, authCode);
        	System.debug('accessToken : '+accessToken);
        }       
        oAuthService = new OAuthService__c(id = serviceId);
        try{
        	if(accessToken != null && accessToken != ''){
	        	oAuthService.Access_Token__c = accessToken;
	        	update oAuthService;
        		userAuthorized = true;
        	}
        }catch(Exception ex){
        	message = ex.getMessage();
        	System.debug('Exception caught : '+ex.getMessage());
        }
        return null;
    }
    
    public Pagereference goToService(){
    	Pagereference pageRef = new Pagereference('/'+serviceId);
    	return pageRef;
    }
}
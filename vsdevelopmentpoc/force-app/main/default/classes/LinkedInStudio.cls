public with sharing class LinkedInStudio {
	
	public boolean userAuthorized {get;set;}
	public LinkedIn linkedInIns {get;set;}
	public OAuthService__c oAuthService {get;set;}
	
	private Id serviceId {get;set;}
    private String accessToken {get;set;}
    
    public LinkedInStudio(){
    	linkedInIns = new LinkedIn(UserInfo.getUserId());
        serviceId = Apexpages.currentPage().getParameters().get('id');
        if(oAuthService == null){
        	oAuthService = [select id, Access_Token__c from OAuthService__c where id = : serviceId];
        	if(oAuthService != null && oAuthService.Access_Token__c != null && oAuthService.Access_Token__c.trim() != ''){
        		  userAuthorized = true;
        	}
        }
    }
    
    public Pagereference getProfileData(){
    	Pagereference p = linkedInIns.getProfileInformation(serviceId, oAuthService.Access_Token__c);
    	return p;
    }
    
    public Pagereference reDirectToAuthenticateUser(){
    	Pagereference pageRef = new Pagereference('/apex/LinkedInAuthenticateUser?id='+serviceId);
    	pageRef.setRedirect(true);
    	return pageRef;
    }

}
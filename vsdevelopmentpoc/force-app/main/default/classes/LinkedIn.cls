public with sharing virtual class LinkedIn{
    
    public static final String LINKED_IN_API_URL = 'https://api.linkedin.com/v1';
    public static final String LINKED_OAUTH_SERVICE_NAME = 'LinkedIn';
    private String sfdcUserId;
    private OAuth_LinkedIn oAuthLNObj; 
    
    public LinkedIn(String userId){
        sfdcUserId = userId;
    }
    
    // To authorize (get OAuth Code) the user using OAuth 2.0
    public PageReference getAuthCode(Id serviceId, Pagereference successRedirectPage){
    	OAuthService__c service = [SELECT consumer_key__c, consumer_secret__c, authorization_url__c FROM OAuthService__c WHERE id = :serviceId];
        String authUrl = service.authorization_url__c+'?response_type=code&client_id='+service.Consumer_Key__c+'&scope=r_fullprofile&state=amsreoContactCheck15798643&redirect_uri=https://'+ApexPages.currentPage().getHeaders().get('Host')+successRedirectPage.getUrl()+'?id='+serviceId;
        System.debug('URL is:'+authUrl);
        if(authUrl==null){
        	return null;
        }else{
          	return new PageReference(authUrl);
        }
    }
    
    // To authorize (get Access Token) the user using OAuth 2.0
    public String getAccessToken(Id serviceId, Pagereference successRedirectPage, String authCode){
    	OAuthService__c service = [SELECT request_token_url__c, access_token_url__c, consumer_key__c, 
                      consumer_secret__c, authorization_url__c FROM OAuthService__c where id = : serviceId];
		
    	String accessToken;
    	
    	Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(service.access_token_url__c+'?grant_type=authorization_code&code='+authCode+'&client_id='+service.Consumer_Key__c+'&client_secret='+service.Consumer_Secret__c+'&redirect_uri=https://'+ApexPages.currentPage().getHeaders().get('Host')+successRedirectPage.getUrl()+'?id='+serviceId);

        HttpResponse res = null;
        res = h.send(req);
        
        Map<String,Object> responseDataMap = (Map<String,Object>)Json.deserializeUntyped(res.getBody());
        
        if(responseDataMap != null && responseDataMap.size() > 0 && responseDataMap.get('error') != null){
	        ApexPages.Message msgCannotPost = new ApexPages.Message(ApexPages.Severity.ERROR, string.valueOf(responseDataMap.get('error')));
	        ApexPages.addMessage(msgCannotPost);
	        return null;
	    }else if(responseDataMap != null && responseDataMap.size() > 0 && responseDataMap.get('access_token') != null){
	        try{
		        accessToken = String.valueOf(responseDataMap.get('access_token'));		        		        
	        }catch(Exception ex){
	        	System.debug('Exception caught : '+ex.getMessage());
	        }
	    }
        
        if(res.getBody()==null){
        	return null;
        }else{
          	return accessToken;
        }
    }
    
    public Pagereference getProfileInformation(Id serviceId, String accessToken){
    	
    	Http h = new Http();
    	HttpRequest httpReq = createRequestforOAuth2('/people/~?secure-urls=true&oauth2_access_token='+accessToken, null, null);
    	
    	HttpResponse httpRes = h.send(httpReq);
        system.debug('httpRes : '+httpRes.getBody());
        
        Dom.Document doc = new Dom.Document(); 
		doc.load(httpRes.getBody());		
		Dom.XMLNode userNode = doc.getRootElement();
		
		OAuthService__c service = parseResponse(userNode, serviceId);
		
		update service;
                
        if(httpRes != null && httpRes.getStatusCode() == 200){
	        GenericParser genParser = new GenericParser();
			
			System.debug('genParser.parseXMLResponse() : '+genParser.parseXMLResponse(httpRes.getBody()));			
        }        
    	return new Pagereference('/'+serviceId);	
    }
    
    public OAuthService__c parseResponse(Dom.XMLNode userNode, Id serviceId){
        OAuthService__c service = new OAuthService__c(Id = serviceId);
        System.debug('the root element name is-->' + userNode.getName());        
        if(userNode!=null){
            for(Dom.Xmlnode userChildNode : userNode.getChildElements()){				
                System.debug('userChildNode**'+userChildNode);
                if(userChildNode.getName()=='first-name'){
                    service.First_Name__c = userChildNode.getText();
                    System.debug('first-name : '+userChildNode.getText());
                }   
                if(userChildNode.getName()=='last-name'){
                    service.Last_Name__c = userChildNode.getText();
                    System.debug('last-name : '+userChildNode.getText());
                }
                if(userChildNode.getName()=='headline'){
                    service.Profile_Title__c = userChildNode.getText();
                    System.debug('headline: '+userChildNode.getText());
                }
                if(userChildNode.getName()=='site-standard-profile-request'){
                    Dom.Xmlnode userGrandChildNode = userChildNode.getChildElement('url',null);
                    String profileURL = userGrandChildNode.getText();
                    profileURL = profileURL.substring(0, profileURL.indexOf('&'));
                    service.Profile_URL__c = profileURL;
                    System.debug('URL: '+userGrandChildNode.getText());
                }                
            }	                
        }
		return service;        
	}
    
    protected virtual Httprequest createRequestforOAuth2(String path, String method, DOM.Document request){
    	
        HttpRequest req = new HttpRequest();
        req.setEndpoint(LINKED_IN_API_URL  + path);
        req.setMethod(method == null ? 'GET' : method);
        req.setTimeout(60000);
        
        if (request != null){
            req.setBodyDocument(request);
        }
        
        return req;
    }
    
    // To authorize the user using OAuth 1.0
    public PageReference oAuthAuthorize(Id serviceId, Pagereference successRedirectPage){
        //Use the OAuth LinkedIn class
        oAuthLNObj = new OAuth_LinkedIn();
        String authUrl = oAuthLNObj.newAuthorization(serviceId, successRedirectPage);
        System.debug('URL is:'+authUrl);
        if(authUrl==null){
        	return null;
        }else{
          	return new PageReference(authUrl);
        }
    }
    
    public String updateUserShare(Share s){
        HttpRequest req = createRequest('/people/~/shares','POST', s.toXML());
        HttpResponse resp = executeLinkedInRequest(req);
        return getResponseBody(req, resp);
    }
    
    protected virtual HttpRequest createRequest(String path, String method, DOM.Document request){        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(LINKED_IN_API_URL  + path);
        req.setMethod(method == null ? 'GET' : method);
        req.setHeader('Content-Type', 'text/xml');
        req.setTimeout(60000);
        
        if (request != null)
            req.setBodyDocument(request); 
        
        if (oAuthLNObj == null){
            oAuthLNObj = new OAuth_LinkedIn();       
            if (!oAuthLNObj.setService(LINKED_OAUTH_SERVICE_NAME, sfdcUserId)){
                System.debug('Didnt work:'+oAuthLNObj.message);
                throw new AuthenticationException(oAuthLNObj.message);
            }
        }
        
        oAuthLNObj.sign(req); 
        return req;   
    }
    
    protected virtual HttpResponse executeLinkedInRequest(HttpRequest req){
        HttpResponse res = new Http().send(req);
        
        if (req.getMethod() == 'POST' && res.getStatusCode() != 201){
            System.debug('OAuth header:'+res.getHeader('oauth_problem'));
            throw new TwitterApiException (res.getBody());
        }else if (req.getMethod() == 'GET' && res.getStatusCode() != 200)
            throw new TwitterApiException (res.getBody());

        return res;
    }
    
    protected virtual String getResponseBody(HttpRequest req, HttpResponse resp ){
        return resp.getBody();
    }
        
    public class Share{
        public String comment {get;set;}
        public String title {get;set;}
        public String submittedUrl {get;set;}
        public String submittedImageUrl {get;set;}
        public String description {get;set;}
        public String visibility {get;set;}
        public Boolean updateTwitter {get;set;}
        
        public Share(){
            updateTwitter = false;
        }
        
        public DOM.Document toXML(){
            DOM.Document doc = new DOM.Document();
            Dom.XmlNode req = doc.createRootElement('share', null, null);
            req.addChildElement('comment', null, null).addTextNode(comment);
            
            if (title != null || submittedImageUrl != null || submittedUrl != null || description != null){
                Dom.XmlNode c = req.addChildElement('content', null, null);
                c.addChildElement('title', null, null).addTextNode((title != null)?title:'');
                c.addChildElement('submitted-url', null, null).addTextNode((submittedUrl != null)?submittedUrl:'');
                c.addChildElement('submitted-image-url', null, null).addTextNode((submittedImageUrl != null)?submittedImageUrl:'');
                c.addChildElement('description', null, null).addTextNode((description!= null)?description:'');
            }
            req.addChildElement('visibility', null, null).addChildElement('code', null, null).addTextNode((visibility != null)?visibility:'connections-only');
            return doc;
        }        
    }
    
    public virtual class TwitterException extends Exception {}
    public class AuthenticationException extends Exception {}
    public class TwitterApiException extends Exception {}
}
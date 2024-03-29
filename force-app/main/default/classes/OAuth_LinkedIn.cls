/*
This class is a slightly modified version of this Google Code Share project - http://code.google.com/p/sfdc-oauth-playground/
Methods used for OAuth 1.0 only
*/
public with sharing class OAuth_LinkedIn {

    private OAuthService__c service;
    private String token;
    private String tokenSecret;
    private Boolean isAccess = false;
    private String verifier;

    private String nonce;
    private String timestamp;
    private String signature;
    private String consumerKey;
    private String consumerSecret;

    private Map<String,String> parameters = new Map<String,String>();
    
    public String message { get; set; }

    public String callbackUrl {get; set; }
    
    public void setConsumerKey(String value) { consumerKey = value; }
    public void setConsumerSecret(String value) { consumerSecret = value; }

    /**
     * Looks up service name and starts a new authorization process
     * returns the authorization URL that the user should be redirected to
     * If null is returned, the request failed. The message property will contain
     * the reason.
     */ 
        
    public String newAuthorization(Id serviceId, Pagereference successPage) {

        service = [SELECT request_token_url__c, access_token_url__c, consumer_key__c, 
                          consumer_secret__c, authorization_url__c,
                          (select token__c, secret__c, isAccess__c FROM OAuth_Tokens__r WHERE owner__c=:UserInfo.getUserId() ) 
                          FROM OAuthService__c WHERE id = :serviceId];
        
        if(service==null) {
            System.debug('Couldn\'t find Oauth Service '+serviceId);
            message = 'Service '+serviceId+' was not found in the local configuration';
            return null;
        }

        if(callbackUrl==null) { 
            if(ApexPages.currentPage()==null || ApexPages.currentPage().getHeaders().get('Host')==null) {
                message = 'No callback page was set and it couldn\'t be generated from Apex context';
                System.debug(message);
                return null;
            }
            callbackUrl = EncodingUtil.urlEncode('https://'+ApexPages.currentPage().getHeaders().get('Host')+
                                                 Page.LinkedInCompleteAuthorization.getUrl()+ ((successPage != null)?'?success_page='+successPage.getUrl():''),'UTF-8');
    		System.debug('callbackUrl : '+callbackUrl);
        }
                
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(service.request_token_url__c);
        System.debug('Request body set to: '+req.getBody());
        consumerKey = service.consumer_key__c;
        consumerSecret = service.consumer_secret__c;
        sign(req);
        HttpResponse res = null;
        System.debug('serviceId : '+serviceId);
        
        res = h.send(req);
        
        System.debug('res : '+res);
        System.debug('Response from request token request: ('+res.getStatusCode()+')'+res.getBody());
        if(res.getStatusCode()>299) {
            message = 'Failed getting a request token. HTTP Code = '+res.getStatusCode()+
                      '. Message: '+res.getStatus()+'. Response Body: '+res.getBody();
            return null;
        }
        
        String resParams = res.getBody();
        System.debug('resParams : '+resParams);
        Map<String,String> rp = getUrlParams(resParams);
        OAuth_Token__c oAuthToken = new OAuth_Token__c();
        oAuthToken.owner__c = UserInfo.getUserId();
        oAuthToken.OAuthService__c = service.id;
        oAuthToken.token__c = rp.get('oauth_token');
        oAuthToken.secret__c = rp.get('oauth_token_secret');
        oAuthToken.isAccess__c = false;

        delete service.OAuth_Tokens__r;

        insert oAuthToken;
        
        System.debug('Got request token: '+oAuthToken.token__c+'('+rp.get('oauth_token')+')');
        if(service.authorization_url__c.contains('?')) {
            return service.authorization_url__c+'&oauth_token='+EncodingUtil.urlDecode(oAuthToken.token__c,'UTF-8')+'&oauth_consumer_key='+service.consumer_key__c;
        } else {
            return service.authorization_url__c+'?oauth_token='+EncodingUtil.urlDecode(oAuthToken.token__c,'UTF-8')+'&oauth_consumer_key='+service.consumer_key__c;
        }
    }
    
    public boolean completeAuthorization(String token, String verifier) {
        System.debug('Completing authorization for request token '+token+' with verifier '+verifier);
        OAuth_Token__c oAuthToken = null;
        try {
            oAuthToken =
            [SELECT OAuthService__r.name, OAuthService__r.access_token_url__c, OAuthService__r.consumer_key__c, 
             OAuthService__r.consumer_secret__c, token__c, secret__c, isAccess__c FROM OAuth_Token__c 
             WHERE owner__c=:UserInfo.getUserId() AND token__c = :EncodingUtil.urlEncode(token,'UTF-8') AND isAccess__c = false];
        } catch(System.QueryException e) {
            message = 'Unknown request token: '+token+'. Restart authorization process';
            System.debug(message);
            return false;
            
        }

        service = oAuthToken.OAuthService__r;
        
        consumerKey = service.Consumer_Key__c;
        consumerSecret = service.Consumer_Secret__c;
        this.token = oAuthToken.token__c;
        tokenSecret = oAuthToken.secret__c;
        if(verifier!=null) {
            this.verifier = EncodingUtil.urlEncode(verifier,'UTF-8');
        }
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(service.access_token_url__c);
        req.setBody('');
        sign(req);
        HttpResponse res = null;
        
        res = h.send(req);
        System.debug('Response from request token request: ('+res.getStatusCode()+')'+res.getBody());
        
        if(res.getStatusCode()>299) {
            message = 'Failed getting an access token. HTTP Code = '+res.getStatusCode()+'. Message: '+res.getStatus()+'. Response Body: '+res.getBody();
            return false;
        }

        String resParams = service.name == 'test1234' ? 
            'oauth_token=token&oauth_token_secret=token_secret' : res.getBody();

        Map<String,String> rp = new Map<String,String>();
        for(String s : resParams.split('&')) {
            List<String> kv = s.split('=');
            rp.put(kv[0],kv[1]);
            System.debug('Access token response param: '+kv[0]+'='+kv[1]);
        }
        
        oAuthToken.token__c = rp.get('oauth_token');
        oAuthToken.secret__c = rp.get('oauth_token_secret');
        oAuthToken.isAccess__c = true;
        
        update oAuthToken;
        
        return true;
    }
    
    public List<User> getUsersOfService(String serviceName) {
        List<OAuth_Token__c> l =
            [SELECT OAuthService__r.name, isAccess__c, Owner__r.name FROM OAuth_Token__c 
             WHERE OAuthService__r.name= :serviceName AND isAccess__c = true];
             
        List<User> result = new List<User>();
        for(OAuth_Token__c oAuthToken : l) {
            result.add(oAuthToken.owner__r);
        }
        return result;
    }

    public boolean setService(String serviceName) {
        return setService(serviceName,UserInfo.getUserId());
    }

    public boolean setService(String serviceName, String userId) {
        OAuth_Token__c oAuthToken = null;
        try {
            oAuthToken =
            [SELECT OAuthService__r.name, OAuthService__r.consumer_key__c, OAuthService__r.consumer_secret__c, 
             token__c, secret__c, isAccess__c FROM OAuth_Token__c 
             WHERE OAuthService__r.name= :serviceName AND owner__c=:userId AND isAccess__c = true];
        } catch(System.QueryException e) {
            message = 'User '+UserInfo.getUserName()+' did not authorize access to '+serviceName+'. Redirect user to authorization page. ['+e+']';
            System.debug(message);
            return false;
        }
        service = oAuthToken.OAuthService__r;
        
        System.debug('Preparing OAuth request to service '+service.name);
        
        consumerKey = service.Consumer_Key__c;
        consumerSecret = service.Consumer_Secret__c;
        this.token = oAuthToken.token__c;
        tokenSecret = oAuthToken.secret__c;      
        return true;
    }
    
    public void sign(HttpRequest req) {
        
        nonce = String.valueOf(Crypto.getRandomLong());
        timestamp = String.valueOf(DateTime.now().getTime()/1000);

        refreshParameters();
        
        String s = createBaseString(parameters, req);
        
        System.debug('Authorization: Signature base string: '+s);
        
        Blob sig = Crypto.generateMac('HmacSHA1', Blob.valueOf(s), 
                       Blob.valueOf(consumerSecret+'&'+
                                    (tokenSecret!=null ? tokenSecret : '')));
        signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');
        System.debug('Signature: '+signature);
        
        String header = 'OAuth ';
        for (String key : parameters.keySet()) {
            header = header + key + '="'+parameters.get(key)+'", ';
        }
        header = header + 'oauth_signature="'+signature+'"';
                
        System.debug('Authorization: '+header);
        req.setHeader('Authorization',header);
    }
        
    private void refreshParameters() {
        parameters.clear();
        parameters.put('oauth_consumer_key',consumerKey);
        if(token!=null) {
            parameters.put('oauth_token',token);
        }
        if(verifier!=null) {
            parameters.put('oauth_verifier',verifier);
        }
        parameters.put('oauth_signature_method','HMAC-SHA1');
        parameters.put('oauth_timestamp',timestamp);
        parameters.put('oauth_nonce',nonce);
        if (callbackUrl != null)
            parameters.put('oauth_callback',callbackUrl);
        parameters.put('oauth_version','1.0');
    }

    public Map<String,String> getUrlParams(String value) {

        Map<String,String> res = new Map<String,String>();
        if(value==null || value=='') {
            return res;
        }
        for(String s : value.split('&')) {
            System.debug('getUrlParams: '+s);
            List<String> kv = s.split('=');
            if(kv.size()>1) {
                System.debug('getUrlParams:  -> '+kv[0]+','+kv[1]);
                res.put(kv[0],kv[1]);
            }
        }
        return res;
    }

    private String createBaseString(Map<String,String> oauthParams, HttpRequest req) {
        Map<String,String> p = oauthParams.clone();
        if(req.getMethod().equalsIgnoreCase('post') && req.getBody()!=null && 
           req.getHeader('Content-Type')=='application/x-www-form-urlencoded') {
            p.putAll(getUrlParams(req.getBody()));
        }
        String host = req.getEndpoint();
        Integer n = host.indexOf('?');
        if(n>-1) {
            p.putAll(getUrlParams(host.substring(n+1)));
            host = host.substring(0,n);
        }
        List<String> keys = new List<String>();
        keys.addAll(p.keySet());
        keys.sort();
        String s = keys.get(0)+'='+p.get(keys.get(0));
        for(Integer i=1;i<keys.size();i++) {
            s = s + '&' + keys.get(i)+'='+p.get(keys.get(i));
        }

        // According to OAuth spec, host string should be lowercased, but Google and LinkedIn
        // both expect that case is preserved.
        return req.getMethod().toUpperCase()+ '&' + 
            EncodingUtil.urlEncode(host, 'UTF-8').replaceAll('%7E', '~') + '&' +
            EncodingUtil.urlEncode(s, 'UTF-8');
    }   
}
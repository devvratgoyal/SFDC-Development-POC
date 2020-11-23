@RestResource(urlMapping='/case/*/close')
global with sharing class CaseCloseResource {
    @HttpPost
    global static void closeCase (String closeReason) {
        // Parse context
        RestRequest req = RestContext.request;
        String[] uriParts = req.requestURI.split('/');
        Id caseId = uriParts[2];
        // Call the service
        CaseService.closeCases(
            new Set<ID> { caseId }, closeReason);     
    }
}
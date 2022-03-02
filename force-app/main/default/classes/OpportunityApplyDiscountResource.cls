/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-05-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   08-05-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@RestResource(urlMapping='/opportunity/*/applydiscount')
global with sharing class OpportunityApplyDiscountResource {
    @HttpPost
    global static void applyDiscount(Decimal discountPercentage) {
        // Parse context
        RestRequest req = RestContext.request;
        String[] uriParts = req.requestURI.split('/');
        Id opportunityId = uriParts[2];
        // Call the service
        OpportunitiesService.applyDiscounts(
            new Set<Id> { opportunityId }, discountPercentage);     
    }
}
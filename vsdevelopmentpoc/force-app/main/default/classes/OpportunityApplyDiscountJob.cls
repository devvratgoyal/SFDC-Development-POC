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
public with sharing class OpportunityApplyDiscountJob implements Database.Batchable<SObject> {
    
    public Decimal DiscountPercentage {get;private set;}
    public Set<Id> idSet {get;private set;}
    
    public OpportunityApplyDiscountJob(Set<Id> idSet, Decimal discountPercentage) {
        this.idSet = idSet;
        this.DiscountPercentage = discountPercentage;
    }
    
    public Database.QueryLocator start(Database.BatchableContext ctx) {
        // Opportunities to discount
        return new OpportunitiesSelector().queryLocatorById(idSet);
        //return new OpportunitiesSelector().queryLocatorByFilter('StageName = \'Negotiation/Review\'');

    }
    public void execute(Database.BatchableContext BC, List<sObject> scope) {        
        try {
          // Call the service           
          OpportunitiesService.applyDiscounts(new Map<Id,SObject>(scope).keySet(), DiscountPercentage);
        } catch (Exception e) {
            // Email error, log error, chatter error etc..
        }
    }
    public void finish(Database.BatchableContext ctx) { }    
}
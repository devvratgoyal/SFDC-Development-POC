/**
 * @File Name          : Opportunities.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : Dev Goyal
 * @Last Modified On   : 11-05-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/26/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class Opportunities extends fflib_SObjectDomain{
    public Opportunities(List<Opportunity> sObjectList) {
        super(sObjectList);
        //Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Opportunities(sObjectList);
        }
    }

    public override void onApplyDefaults() {
        // Apply defaults to Opportunities
        for(Opportunity opportunity : (List<Opportunity>) Records) {
            opportunity.Description = 'Default Description added';
        }
    }
    
    public override void onValidate() {
        // Validate Opportunities
        for(Opportunity oppy : (List<Opportunity>) Records) {
            if(oppy.Type != null && oppy.Type.startsWith('Existing') && oppy.AccountId == null) {
                oppy.AccountId.addError('You must provide an Account when ' +
                    'creating Opportunities for existing Customers.');
            }
        }
    }
    
    public override void onValidate(Map<Id,SObject> existingRecords) {
        // Validate changes to Opportunities
        for(Opportunity oppy : (List<Opportunity>) Records) {
            Opportunity existingOpp = (Opportunity) existingRecords.get(oppy.Id);
            if(oppy.Type != existingOpp.Type) {
                oppy.Type.addError('You cannot change the Opportunity type once it has been created');
            }
        }
    }

    public override void onAfterInsert(){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Account.SObjectType,
                OpportunityLineItem.SObjectType
            }
        );

        set<Id> accountIds = new set<Id>();
        for(Opportunity oppy: (list<Opportunity>) Records){
            accountIds.add(oppy.AccountId);
            //uow.registerNew(new OpportunityLineItemsService().createDefaultLineItem(oppy.Id));
        }
        
        Accounts accounts = new Accounts(new AccountsSelector().selectSObjectsById(accountIds));        
        accounts.updateOpportunityActivity(uow);
            
        uow.commitWork();
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords){
        for(Opportunity oppy: (list<Opportunity>) Records){
            Opportunity existingOppy =  (Opportunity) existingRecords.get(oppy.Id);
            if(oppy.Name != existingOppy.Name){
                oppy.Name.addError('You cannot change the Opportunity name once it has been created');
            }
        }
    }
    
    public void applyDiscount(Decimal discountPercentage, fflib_SObjectUnitOfWork uow) {
        // Calculate discount factor
        Decimal factor = 1 - (discountPercentage==null ? 0 : discountPercentage / 100);
        // Opportunity lines to apply discount to
        List<OpportunityLineItem> linesToApplyDiscount = new List<OpportunityLineItem>();
        
        // Apply discount
        for(Opportunity opportunity : (List<Opportunity>) Records) {
            // Apply to the Opportunity Lines?
            if(opportunity.OpportunityLineItems!=null && opportunity.OpportunityLineItems.size()>0) {
                // Collect lines to apply discount to
                linesToApplyDiscount.addAll(opportunity.OpportunityLineItems);
            } else {
                // Adjust the Amount on the Opportunity if no lines
                opportunity.Amount = opportunity.Amount * factor;
                uow.registerDirty(opportunity);
            }
        }      
        // Apply discount to lines
        OpportunityLineItems lineItems = new OpportunityLineItems(linesToApplyDiscount);
        lineItems.applyDiscount(discountPercentage, uow);
    }

    public void applyDiscount(map<Id, Decimal> oppyIdsDiscountMap, fflib_SObjectUnitOfWork uow){
        // Apply discount
        for(Opportunity opportunity : (List<Opportunity>) Records) {
            Decimal discountPercentage = oppyIdsDiscountMap.get(opportunity.Id);
            Decimal factor = 1 - (discountPercentage==null ? 0 : discountPercentage / 100);
            
            // Apply to the Opportunity Lines?
            if(opportunity.OpportunityLineItems!=null && opportunity.OpportunityLineItems.size()>0) {
                // Apply discount to lines
                OpportunityLineItems lineItems = new OpportunityLineItems(opportunity.OpportunityLineItems);
                lineItems.applyDiscount(discountPercentage, uow);
            } else {
                // Adjust the Amount on the Opportunity if no lines
                opportunity.Amount = opportunity.Amount * factor;
                uow.registerDirty(opportunity);
            }
            
        }
    }
    
}
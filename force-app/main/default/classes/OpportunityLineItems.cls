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
public with sharing class OpportunityLineItems extends fflib_SObjectDomain{
    public OpportunityLineItems(List<OpportunityLineItem> sObjectList) {
        super(sObjectList);
        //Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OpportunityLineItems(sObjectList);
        }
    }

    public void applyDiscount(Decimal discountPercentage, fflib_SObjectUnitOfWork uow) {
        // Calculate discount factor
        Decimal factor = 1 - (discountPercentage==null ? 0 : discountPercentage / 100);
        // Apply discount
        for(OpportunityLineItem opportunityLine : (List<OpportunityLineItem>) Records) {
            // Adjust the Amount on the Opportunity if no lines
            opportunityLine.UnitPrice = opportunityLine.UnitPrice * factor;
            uow.registerDirty(opportunityLine);
        }
    }
}
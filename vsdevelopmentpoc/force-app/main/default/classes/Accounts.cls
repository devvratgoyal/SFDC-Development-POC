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
public with sharing class Accounts extends fflib_SObjectDomain{
    public Accounts(List<Account> sObjectList) {
        super(sObjectList);
        //Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Accounts(sObjectList);
        }
    }

    public void updateOpportunityActivity(fflib_SObjectUnitOfWork uow) {
        for(Account account : (List<Account>) Records) {
            account.Description = 'Last Opportunity Raised ' + System.today();
            uow.registerDirty(account);
        }
    }
}
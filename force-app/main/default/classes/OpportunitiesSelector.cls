/**
 * @File Name          : OpportunitiesSelector.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 8/5/2020, 6:12:06 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/25/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class OpportunitiesSelector extends fflib_SObjectSelector{
    //Default
    public OpportunitiesSelector() {
        super(false,true,false);
    }

    public OpportunitiesSelector(Boolean enforceObjectAndFieldSecurity) {
        super(false, enforceObjectAndFieldSecurity, enforceObjectAndFieldSecurity);
    }

    public OpportunitiesSelector(Boolean enforceObjectSecurity, Boolean enforceFieldSecurity) {
        super(false, enforceObjectSecurity, enforceFieldSecurity);
    }

    public OpportunitiesSelector(Boolean includeFieldSetFields, Boolean enforceObjectSecurity, Boolean enforceFieldSecurity) {
        super(includeFieldSetFields, enforceObjectSecurity, enforceFieldSecurity);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Opportunity.Id,
            Opportunity.Name,
            Opportunity.Amount,
            Opportunity.StageName,
            Opportunity.AccountId,
            Opportunity.Case__c 
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Opportunity.sObjectType;        
    }

    public override String getOrderBy() {
        return 'Name DESC, Id';
    }
    
    /**
    * @description Overiide the where condition
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 6/6/2020 
    * @param AccountId 
    * @return List<Opportunity> 
    **/
    public List<Opportunity> selectSObjectsByAccountId(set<Id> accountIds){
        return (List<Opportunity>) Database.query(
          newQueryFactory(true)
            .setCondition('accountid IN : accountIds')
            .toSOQL()
        );
    }

    public override List<SObject> selectSObjectsById(Set<ID> idSet) {
        return Database.query(
          newQueryFactory(true)
            .selectField('Account.Name')
            .setCondition('id in :idSet')
            .toSOQL()
        );
    }

    public List<Opportunity> selectSObjectsByIdWithFilter(Set<ID> idSet, String filterCondition) {
        return Database.query(
          newQueryFactory(true)
            .selectField('Account.Name')
            .setCondition(filterCondition)
            .toSOQL()
        );
    }

    public Database.QueryLocator queryLocatorByFilter(String filterCondition){
        return Database.getQueryLocator(
            newQueryFactory(true)
            .setCondition(filterCondition)
            .toSOQL()
        );
    }

    public List<Opportunity> selectAccountInfoById(Set<ID> idSet) {
        return (List<Opportunity>) Database.query(
          newQueryFactory(false)
            .selectField('Account.Name')
            .selectfield('Account.AccountNumber')
            .selectField('Account.Owner.Name')
            .setCondition('id in :idSet')
            .toSOQL()
        );
    }

    public List<Opportunity> selectSObjectsByIdWithProducts(Set<ID> idSet) {
        
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory();
        //Query parent fields on Primary Object
        new CasesSelector().configureQueryFactoryFields(opportunitiesQueryFactory, 'Case__r');
        //Adding sub Query and add condition
        fflib_QueryFactory lineItemsQueryFactory = 
            new OpportunityLineItemsSelector().addQueryFactorySubselect(opportunitiesQueryFactory).setCondition('UnitPrice > 0');
        
        //Query Parent fields on SubQueryObject  
        new PricebookEntriesSelector().configureQueryFactoryFields(lineItemsQueryFactory, 'PricebookEntry');
        new ProductsSelector().configureQueryFactoryFields(lineItemsQueryFactory, 'PricebookEntry.Product2');

        return (List<Opportunity>) Database.query(
          opportunitiesQueryFactory
            .selectField('Account.Name')
            .selectfield('Account.AccountNumber')
            .selectField('Account.Owner.Name')
            .setCondition('id in :idSet')
            .toSOQL()
        );
    }

}
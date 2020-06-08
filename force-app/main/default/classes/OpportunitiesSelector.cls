/**
 * @File Name          : OpportunitiesSelector.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 6/7/2020, 2:11:21 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/25/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class OpportunitiesSelector extends fflib_SObjectSelector{
    public OpportunitiesSelector() {
        super(false,false,false);
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

    public List<Opportunity> selectById(Set<ID> idSet) {
        return (List<Opportunity>) Database.query(
          newQueryFactory(true)
            .selectField('Account.Name')
            .selectfield('Account.AccountNumber')
            .selectField('Account.Owner.Name')
            .setCondition('id in :idSet')
            .toSOQL()
        );
    }

    public List<Opportunity> selectByIdWithProducts(Set<ID> idSet) {
        
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory();
        new CasesSelector().configureQueryFactoryFields(opportunitiesQueryFactory, 'Case__r');
        
        fflib_QueryFactory lineItemsQueryFactory = 
            new OpportunityLineItemsSelector().addQueryFactorySubselect(opportunitiesQueryFactory);

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
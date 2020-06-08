/**
 * @File Name          : OpportunitiesService.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 6/5/2020, 1:51:25 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/24/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class OpportunitiesService {
    public OpportunitiesService() {

    }

    /**
    * @description Fetch aggregate Opportunities data
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 4/26/2020 
    * @param oppyClosedDate Latest closed date of the opportunities  
    * @return list<AggregateResult> list of aggregate Opportunities data group by owner id
    **/
    public static list<AggregateResult> fetchAggrOppysAfterCreateDate(Date oppyClosedDate, String groupByFieldName, String StageName){
        
        Map<Schema.SObjectField,String> queryFieldWithFunction = new map<Schema.SObjectField,String>();
        queryFieldWithFunction.put(Opportunity.Id,'Count:noOfOpportunity');
        queryFieldWithFunction.put(Opportunity.Ownerid,'');
        queryFieldWithFunction.put(Opportunity.Owner.name,'max:Owner');
        queryFieldWithFunction.put(Opportunity.Createddate,'max:maxCreatedDate');
        queryFieldWithFunction.put(Opportunity.Amount,'sum:totalOppyValue');

        String whereClause = 'LeadSource != \'\'';
        if(StageName!=''){
            whereClause += ' and StageName = \''+StageName+ '\'';
        }
        if(oppyClosedDate <> null){
            whereClause += ' and CloseDate <= '+ UtilitiesService.getFormattedDate(oppyClosedDate);
        }
        
        return UtilitiesService.fetchAggregateSobject(Opportunity.getSObjectType(), queryFieldWithFunction, whereClause, groupByFieldName);
        
    }

    public static void applyDiscounts(Set<Id> opportunityIds, Decimal discountPercentage) {
        // Validate parameters
        if(opportunityIds==null || opportunityIds.size()==0)
            throw new OpportunityServiceException('Opportunities not specified.');
        if(discountPercentage<0 || discountPercentage>100)
            throw new OpportunityServiceException('Invalid discount to apply.');
        // Query Opportunities and Lines (SOQL inlined for this example, see Selector pattern in later module)
        /*List<Opportunity> opportunities = [select Amount, (select UnitPrice from OpportunityLineItems)
                                                from Opportunity where Id in :opportunityIds];*/
        List<Opportunity> opportunities = new OpportunitiesSelector().selectByIdWithProducts(opportunityIds);
        // Update Opportunities and Lines (if present)
        //List<Opportunity> oppsToUpdate = new List<Opportunity>();
        //List<OpportunityLineItem> oppLinesToUpdate = new List<OpportunityLineItem>();
        // Create a Unit Of Work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SObjectType,
                OpportunityLineItem.SObjectType
            }
        );

        Decimal factor = 1 - (discountPercentage==null ? 0 : discountPercentage / 100);
        for(Opportunity opportunity : opportunities) {
            // Apply to Opportunity Amount
            if(opportunity.OpportunityLineItems!=null && opportunity.OpportunityLineItems.size()>0) {
                for(OpportunityLineItem oppLineItem : opportunity.OpportunityLineItems) {
                    oppLineItem.UnitPrice = oppLineItem.UnitPrice * factor;
                    uow.registerDirty(oppLineItem);
                }
            } else {
                opportunity.Amount = opportunity.Amount * factor;
                uow.registerDirty(opportunity);
            }
        }
        
        uow.commitWork();
    }

    public static void applyDiscounts(List<ApplyDiscountInfo> discountInfos) {
        // Validate parameters
        if(discountInfos==null || discountInfos.size()==0)
            throw new OpportunityServiceException('Discount information not specified.');
        //if(discountPercentage<0 || discountPercentage>100)
          //  throw new OpportunityServiceException('Invalid discount to apply.');
        // Query Opportunities and Lines (SOQL inlined for this example, see Selector pattern in later module)
        map<Id, Decimal> oppyIdsDiscountMap = new map<Id, Decimal>();
        for(ApplyDiscountinfo discountInfo: discountInfos){
            oppyIdsDiscountMap.put(discountInfo.OpportunityId, discountInfo.DiscountPercentage);
        }
        List<Opportunity> opportunities = new OpportunitiesSelector().selectByIdWithProducts(oppyIdsDiscountMap.keySet());
        // Update Opportunities and Lines (if present)
        //List<Opportunity> oppsToUpdate = new List<Opportunity>();
        //List<OpportunityLineItem> oppLinesToUpdate = new List<OpportunityLineItem>();
        // Create a Unit Of Work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SObjectType,
                OpportunityLineItem.SObjectType
            }
        );

        for(Opportunity opportunity : opportunities) {
            Decimal discountPercentage = oppyIdsDiscountMap.get(opportunity.Id);
            Decimal factor = 1 - (discountPercentage==null ? 0 : discountPercentage / 100);
            // Apply to Opportunity Amount
            if(opportunity.OpportunityLineItems!=null && opportunity.OpportunityLineItems.size()>0) {
                for(OpportunityLineItem oppLineItem : opportunity.OpportunityLineItems) {
                    oppLineItem.UnitPrice = oppLineItem.UnitPrice * factor;
                    uow.registerDirty(oppLineItem);
                }
            } else {
                opportunity.Amount = opportunity.Amount * factor;
                uow.registerDirty(opportunity);
            }
        }
        
        uow.commitWork();
    }
    public class ApplyDiscountInfo {
        public Id OpportunityId;
        public Decimal DiscountPercentage;
    }
    public class OpportunityServiceException extends Exception {} 
     
}
/**
 * @File Name          : OpportunitiesService.cls
 * @Description        : 
 * @Author             : Dev Goyal
 * @Group              : 
 * @Last Modified By   : Dev Goyal
 * @Last Modified On   : 09-13-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/24/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class OpportunitiesService {
    
    public static void applyDiscountsOld(Set<Id> opportunityIds, Decimal discountPercentage) {
        // Validate parameters
        if(opportunityIds==null || opportunityIds.size()==0)
            throw new OpportunityServiceException('Opportunities not specified.');
        if(discountPercentage<0 || discountPercentage>100)
            throw new OpportunityServiceException('Invalid discount to apply.');
        // Query Opportunities and Lines (SOQL inlined for this example, see Selector pattern in later module)
        List<Opportunity> opportunities =
            [select Amount, (select UnitPrice from OpportunityLineItems)
             from Opportunity where Id in :opportunityIds];
        // Update Opportunities and Lines (if present)
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<OpportunityLineItem> oppLinesToUpdate = new List<OpportunityLineItem>();
        Decimal factor = 1 - (discountPercentage==null ? 0 : discountPercentage / 100);
        for(Opportunity opportunity : opportunities) {
            // Apply to Opportunity Amount
            if(opportunity.OpportunityLineItems!=null && opportunity.OpportunityLineItems.size()>0) {
                for(OpportunityLineItem oppLineItem : opportunity.OpportunityLineItems) {
                    oppLineItem.UnitPrice = oppLineItem.UnitPrice * factor;
                    oppLinesToUpdate.add(oppLineItem);
                }
            } else {
                opportunity.Amount = opportunity.Amount * factor;
                oppsToUpdate.add(opportunity);
            }
        }
        // Update the database
        SavePoint sp = Database.setSavePoint();
        try {
            update oppLinesToUpdate;
            update oppsToUpdate;
        } catch (Exception e) {
            // Rollback
            Database.rollback(sp);
            // Throw exception on to caller
            throw e;
        }       
    }

    public static void applyDiscounts(Set<Id> opportunityIds, Decimal discountPercentage) {
        // Validate parameters
        if(opportunityIds==null || opportunityIds.size()==0)
            throw new OpportunityServiceException('Opportunities not specified.');
        if(discountPercentage<0 || discountPercentage>100)
            throw new OpportunityServiceException('Invalid discount to apply.');
        
        // Query Opportunities and Lines (SOQL inlined for this example, see Selector pattern in later module)
        List<Opportunity> opportunities = new OpportunitiesSelector().selectSObjectsByIdWithProducts(opportunityIds);
            
        // Create a Unit Of Work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SObjectType, OpportunityLineItem.SObjectType
            }
        );
        
        Opportunities opportunities = new Opportunities(new OpportunitiesSelector().selectSObjectsByIdWithProducts(opportunityIds));
        opportunities.applyDiscount(discountPercentage, uow);
        
        uow.commitWork();
    }

    public static void applyDiscounts(List<ApplyDiscountInfo> discountInfos) {
        // Validate parameters
        if(discountInfos==null || discountInfos.size()==0)
            throw new OpportunityServiceException('Discount information not specified.');
        
            
        map<Id, Decimal> oppyIdsDiscountMap = new map<Id, Decimal>();
        for(ApplyDiscountinfo discountInfo: discountInfos){
            oppyIdsDiscountMap.put(discountInfo.OpportunityId, discountInfo.DiscountPercentage);
        }
        
        // Query Opportunities and Lines (SOQL inlined for this example, see Selector pattern in later module)
        Opportunities opportunities = new Opportunities(new OpportunitiesSelector().selectSObjectsByIdWithProducts(oppyIdsDiscountMap.keySet()));
            
        // Create a Unit Of Work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SObjectType, OpportunityLineItem.SObjectType
            }
        );

        opportunities.applyDiscount(oppyIdsDiscountMap, uow);
        
        uow.commitWork();
    }
    public class ApplyDiscountInfo {
        public Id OpportunityId;
        public Decimal DiscountPercentage;
    }
    public class OpportunityServiceException extends Exception {}
    
    public static void createOpportunitiesWithDetailOld(){
        
        List<Opportunity> opps = new List<Opportunity>();
        List<List<Product2>> productsByOpp = new List<List<Product2>>();
        List<List<PricebookEntry>> pricebookEntriesByOpp = new List<List<PricebookEntry>>();
        List<List<OpportunityLineItem>> oppLinesByOpp = new List<List<OpportunityLineItem>>();
        for(Integer o=0; o<10; o++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Opportunity ' + o;
            opp.StageName = 'Open';
            opp.CloseDate = System.today();
            opps.add(opp);
            List<Product2> products = new List<Product2>();
            List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            for(Integer i=0; i<o+1; i++) {
                Product2 product = new Product2();
                product.Name = opp.Name + ' : Product : ' + i;
                products.add(product);
                PricebookEntry pbe = new PricebookEntry();
                pbe.UnitPrice = 10;
                pbe.IsActive = true;
                pbe.UseStandardPrice = false;
                pbe.Pricebook2Id = Test.getStandardPricebookId();
                pricebookEntries.add(pbe);
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.Quantity = 1;
                oppLineItem.TotalPrice = 10;
                oppLineItems.add(oppLineItem);
            }
            productsByOpp.add(products);
            pricebookEntriesByOpp.add(pricebookEntries);
            oppLinesByOpp.add(oppLineItems);
        }
        // Insert Opportunities
        insert opps;
        // Insert Products
        List<Product2> allProducts = new List<Product2>();
        for(List<Product2> products : productsByOpp) {
            allProducts.addAll(products);
        }
        insert allProducts;
        // Insert Pricebooks
        Integer oppIdx = 0;
        List<PricebookEntry> allPricebookEntries = new List<PricebookEntry>();
        for(List<PriceBookEntry> pricebookEntries : pricebookEntriesByOpp) {
            List<Product2> products = productsByOpp[oppIdx++];
            Integer lineIdx = 0;
            for(PricebookEntry pricebookEntry : pricebookEntries) {
                pricebookEntry.Product2Id = products[lineIdx++].Id;
            }
            allPricebookEntries.addAll(pricebookEntries);
        }
        insert allPricebookEntries;
        // Insert Opportunity Lines
        oppIdx = 0;
        List<OpportunityLineItem> allOppLineItems = new List<OpportunityLineItem>();
        for(List<OpportunityLineItem> oppLines : oppLinesByOpp) {
            List<PricebookEntry> pricebookEntries = pricebookEntriesByOpp[oppIdx];
            Integer lineIdx = 0;
            for(OpportunityLineItem oppLine : oppLines) {
                oppLine.OpportunityId = opps[oppIdx].Id;
                oppLine.PricebookEntryId = pricebookEntries[lineIdx++].Id;
            }
            allOppLineItems.addAll(oppLines);
            oppIdx++;
        }
        insert allOppLineItems;
    }

    public static void createOpportunitiesWithDetail(){
        
        // Create a Unit Of Work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Product2.SObjectType,
                PricebookEntry.SObjectType,
                Opportunity.SObjectType,
                OpportunityLineItem.SObjectType
            }
        );

        // Do some work!
        for(Integer o=0; o<10; o++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'UoW Test Name ' + o;
            opp.StageName = 'Open';
            opp.CloseDate = System.today();
            uow.registerNew(opp);
            for(Integer i=0; i<o+1; i++) {
                Product2 product = new Product2();
                product.Name = opp.Name + ' : Product : ' + i;
                uow.registerNew(product);
                PricebookEntry pbe = new PricebookEntry();
                pbe.UnitPrice = 10;
                pbe.IsActive = true;
                pbe.UseStandardPrice = false;
                pbe.Pricebook2Id = Test.getStandardPricebookId();
                uow.registerNew(pbe, PricebookEntry.Product2Id, product);
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.Quantity = 1;
                oppLineItem.TotalPrice = 10;
                uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
                uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
            }
        }

        uow.commitWork();
    }

    @AuraEnabled
    public static String getAccountIdForOpportunity(Id opportunityId){
        list<Opportunity> listOpportunity = (list<Opportunity>)new OpportunitiesSelector().selectSObjectsById(new set<Id>{opportunityId});
        if(listOpportunity <> null && !listOpportunity.isEmpty()){
            return listOpportunity[0].AccountId;
        }
        return null;
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
     
}
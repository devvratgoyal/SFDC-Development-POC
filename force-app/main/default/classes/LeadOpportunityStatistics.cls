/**
 * @File Name          : LeadOpportunityStatistics.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 5/24/2020, 5:30:45 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/25/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class LeadOpportunityStatistics {
    
    final static String stageName = 'Closed Won';

    /**
    * @description Populate and return Leads and Opportunities aggregate data
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 4/26/2020 
    * @param leadCreateDate starting create date of leads (Input from page)
    * @param oppyClosedDate  Latest closed date of opportunities (Input from page)
    * @return list<LeadOpportunityWrapper> list of wrapper having Leads and Opportunities aggregate data
    **/
    @AuraEnabled
    public static list<LeadOpportunityWrapper> getLeadOpportunity(Date leadCreateDate, Date oppyClosedDate){
        
        // Fetch aggregate Leads data by owner id for given created date        
        list<AggregateResult> listLeads =  LeadsService.fetchAggrLeadsAfterCreateDate(leadCreateDate,'ownerId');
        
        // Fetch aggregate Opportunities data by owner id for given close date         
        list<AggregateResult> listOpportunity = OpportunitiesService.fetchAggrOppysAfterCreateDate(oppyClosedDate, 'ownerId', ConstantsService.stageOppyClosedWon);
        
        //Populate Lead and Opportunity Data into a map of wrapper with ownerid as key
        map<String,LeadOpportunityWrapper> mapLeadOppyWrapper = new map<String,LeadOpportunityWrapper>();        
        mapLeadOppyWrapper = populateWrapperWithLeads(mapLeadOppyWrapper, listLeads);
        mapLeadOppyWrapper = populateWrapperWithOppys(mapLeadOppyWrapper, listOpportunity);
        
        return mapLeadOppyWrapper.values();
    }
    
    /**
    * @description Populate lead data into the wrapper map
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 4/26/2020 
    * @param mapLeadOppyWrapper Map to have the data populated
    * @param listLeads Aggregate Leads data to populate in map of wrapper
    * @return map<String, LeadOpportunityWrapper> map with aggregate leads data by owner id
    **/
    private static map<String,LeadOpportunityWrapper> populateWrapperWithLeads(map<String,LeadOpportunityWrapper> mapLeadOppyWrapper, list<AggregateResult> listLeads){
        
        LeadOpportunityWrapper leadOppyWrapper;
        
        for(AggregateResult agrResult: listLeads){
            leadOppyWrapper = new LeadOpportunityWrapper();
            String leadOwner = (String)agrResult.get('ownerid');
            leadOppyWrapper.owner = (String)agrResult.get('Owner');
            leadOppyWrapper.totalLeads = (Integer)agrResult.get('noOfLeads');
            leadOppyWrapper.totalOpportunities = 0;
            leadOppyWrapper.conversionRate = 0;
            leadOppyWrapper.totalOppyValue = 0;
            mapLeadOppyWrapper.put(leadOwner,leadOppyWrapper);
        }

        return mapLeadOppyWrapper;
    }
    
    /**
    * @description Populate opportunity data into the wrapper map
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 4/26/2020 
    * @param mapLeadOppyWrapper Map to have the data populated
    * @param listOpportunity Aggregate Opportunities data to populate in map of wrapper
    * @return map<String, LeadOpportunityWrapper> map with aggregate leads and opportinities data by owner id
    **/
    private static map<String,LeadOpportunityWrapper> populateWrapperWithOppys(map<String,LeadOpportunityWrapper> mapLeadOppyWrapper, list<AggregateResult> listOpportunity){
        
        LeadOpportunityWrapper leadOppyWrapper;
        
        for(AggregateResult agrResult: listOpportunity){
            
            String oppyOwner = (String)agrResult.get('ownerid');
            // populate opportunities data in the same wrapper instance (used for leads) for the same owner
            if(mapLeadOppyWrapper.containsKey(oppyOwner)){
            	leadOppyWrapper = mapLeadOppyWrapper.get(oppyOwner);
                leadOppyWrapper.owner = (String)agrResult.get('Owner');
                leadOppyWrapper.totalOpportunities = (Integer)agrResult.get('noOfOpportunity');
                Decimal convRate = (Decimal)(leadOppyWrapper.totalOpportunities) / (Decimal)leadOppyWrapper.totalLeads;
                convRate = convRate.setScale(4);
                leadOppyWrapper.conversionRate = convRate;
                leadOppyWrapper.maxCreatedDate = ((DateTime)agrResult.get('maxCreatedDate')).date();
                leadOppyWrapper.totalOppyValue = (Decimal)agrResult.get('totalOppyValue');                
            }else{ // populate opportunities data in new wrapper instance when lead data not available for the owner
                leadOppyWrapper = new LeadOpportunityWrapper();
                leadOppyWrapper.owner = (String)agrResult.get('Owner');
                leadOppyWrapper.totalLeads = 0;
                leadOppyWrapper.totalOpportunities = (Integer)agrResult.get('noOfOpportunity');
                leadOppyWrapper.conversionRate = 0.0;
                leadOppyWrapper.maxCreatedDate = ((DateTime)agrResult.get('maxCreatedDate')).date();
                leadOppyWrapper.totalOppyValue = (Decimal)agrResult.get('totalOppyValue');
            }
            
            mapLeadOppyWrapper.put(oppyOwner,leadOppyWrapper);
        }
        return mapLeadOppyWrapper;
    }

}
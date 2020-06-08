/**
 * @File Name          : LeadsService.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 5/24/2020, 6:35:46 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/24/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class LeadsService {
    
    /**
    * @description Fetch aggregate Lead data
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 4/26/2020 
    * @param leadCreateDate Earliest create date on leads
    * @return list<AggregateResult> list of aggregate Leads data group by owner id
    **/
    public static list<AggregateResult> fetchAggrLeadsAfterCreateDate(Date leadCreateDate, String groupByFieldName){
        
        Map<Schema.SObjectField,String> queryFieldWithFunction = new map<Schema.SObjectField,String>();
        queryFieldWithFunction.put(Lead.Id,'Count:noOfLeads');
        queryFieldWithFunction.put(Lead.Ownerid,'');
        queryFieldWithFunction.put(Lead.Owner.name,'max:Owner');

        String whereClause = 'Createddate >= '+UtilitiesService.getFormattedDateTime(leadCreateDate);
                
        return UtilitiesService.fetchAggregateSobject(Lead.getSObjectType(), queryFieldWithFunction, whereClause, groupByFieldName);
    }

}
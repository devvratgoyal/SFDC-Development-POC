/**
 * @File Name          : UtilitiesService.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 5/24/2020, 5:27:01 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/24/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class UtilitiesService {
    public UtilitiesService() {

    }

    // format start date into soql compliant date time string
    public static string getFormattedDateTime(Date dateObj){
        return String.valueOf(dateObj)+'T00:00:00.000+0000';  
    }
    
    // format end date into soql compliant date format
    public static String getFormattedDate(Date dateObj){
        DateTime dt = DateTime.newInstance(dateObj.year(), dateObj.month(),dateObj.day());
        return dt.format('yyyy-MM-dd');
    }

    public static list<AggregateResult> fetchAggregateSobject(schema.SObjectType queryObject, map<Schema.SObjectField,String> queryFieldWithFunction, String whereClause, String groupByFieldName){
        
        String queryStr = 'select';
        
        for(Schema.SObjectField field : queryFieldWithFunction.keySet()){
            String aliasFunction = queryFieldWithFunction.get(field);
            if(aliasFunction != null && aliasFunction != ''){
                if(aliasFunction.containsIgnoreCase(':')){
                    queryStr += ' '+aliasFunction.split(':').get(0)+'('+field+') '+aliasFunction.split(':').get(1)+','; 
                }else{
                    queryStr += ' '+aliasFunction+'('+field+'),'; 
                }                
            }else{
                queryStr += ' '+field+','; 
            }
        }

        queryStr = queryStr.substring(0, queryStr.length()-1) + ' from '+queryObject;

        if(whereClause != null && whereClause !=''){
            queryStr += ' where '+whereClause;
        }

        if(groupByFieldName != null){
            queryStr += ' group by '+groupByFieldName;
        }else{
            queryStr += ' group by ownerId';
        }

        System.debug('queryStr : '+queryStr);

        return Database.query(queryStr);
    }

}
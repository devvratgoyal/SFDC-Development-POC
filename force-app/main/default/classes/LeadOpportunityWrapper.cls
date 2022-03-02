/**
 * @File Name          : LeadOpportunityWrapper.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 4/28/2020, 8:09:38 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/25/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class LeadOpportunityWrapper {
    
    @AuraEnabled
    public String owner {get;set;}
    @AuraEnabled
    public Integer totalLeads {get;set;}
    @AuraEnabled
    public Integer totalOpportunities {get;set;}
    @AuraEnabled
    public Decimal conversionRate {get;set;}
    @AuraEnabled
    public Date maxCreatedDate {get;set;}
    @AuraEnabled
    public Decimal totalOppyValue {get;set;}

}
/**
 * @File Name          : LeadConvertValidation.trigger
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 1/3/2020, 5:11:25 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/3/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
trigger LeadConvertValidation on Lead (before update) {

    EnableTrigger__mdt istriggerEnabled = [select id,LeadConvert__c from EnableTrigger__mdt where DeveloperName = 'TriggerFlag'];
    if(istriggerEnabled.LeadConvert__c){
        for(Lead l:Trigger.new){
            if(l.LastName.containsIgnoreCase('DoNotConvert')){
                l.addError('Lead is not eligible for conversion');
            }
        }
    }
}
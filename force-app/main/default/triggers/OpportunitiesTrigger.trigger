/**
 * @File Name          : OpportunitiesTrigger.trigger
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 5/26/2020, 3:47:09 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/26/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
trigger OpportunitiesTrigger on Opportunity (before insert, before update, after insert, after update) {
    fflib_SObjectDomain.triggerHandler(Opportunities.Class);
}
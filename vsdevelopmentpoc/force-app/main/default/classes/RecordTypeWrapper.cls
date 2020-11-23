/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-20-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-20-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class RecordTypeWrapper {
    /*******************************************/
    /* Wrapper class to display Record Types  */
    /*****************************************/       
    @AuraEnabled public boolean isDefault{get;set;} 
    @AuraEnabled public string label{get;set;}
    @AuraEnabled public string value{get;set;}
    
    public RecordTypeWrapper (){
        isDefault = false;
        label = '';
        value = '';
    }
}
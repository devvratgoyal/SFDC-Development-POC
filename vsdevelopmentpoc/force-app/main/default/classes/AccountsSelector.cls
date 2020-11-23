/**
 * @File Name          : AccountsSelector.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 6/6/2020, 4:53:10 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class AccountsSelector extends fflib_SObjectSelector{
    public AccountsSelector() {

    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.Name 
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;        
    }
        
}
/**
 * @File Name          : CasesSelector.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 5/25/2020, 6:20:02 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/25/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class CasesSelector extends fflib_SObjectSelector {
    public CasesSelector() {

    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Case.Id,
            Case.Status
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Case.sObjectType;        
    }
}
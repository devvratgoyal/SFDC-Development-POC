/**
 * @File Name          : PricebookEntriesSelector.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 5/25/2020, 5:46:42 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/25/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class PricebookEntriesSelector extends fflib_SObjectSelector {
    public PricebookEntriesSelector() {
        
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PricebookEntry.IsActive,
            PricebookEntry.Name,
            PricebookEntry.Pricebook2Id,
            PricebookEntry.Product2Id,
            PricebookEntry.ProductCode,
            PricebookEntry.UnitPrice,
            PricebookEntry.UseStandardPrice 
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return PricebookEntry.sObjectType;        
    }
    
}
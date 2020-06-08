/**
 * @File Name          : OpportunityLineItemsSelector.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 6/5/2020, 12:43:54 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/25/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class OpportunityLineItemsSelector extends fflib_SObjectSelector{
    public OpportunityLineItemsSelector() {

    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            OpportunityLineItem.Id,
            OpportunityLineItem.UnitPrice,
            OpportunityLineItem.Description,
            OpportunityLineItem.ListPrice,
            OpportunityLineItem.OpportunityId
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return OpportunityLineItem.sObjectType;        
    }
}
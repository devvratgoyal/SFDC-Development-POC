/**
 * @File Name          : ProductsSelector.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 5/25/2020, 6:05:01 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/25/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class ProductsSelector extends fflib_SObjectSelector{
    public ProductsSelector() {

    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Product2.Id,
            Product2.Description,
            Product2.IsActive,
            Product2.Name,
            Product2.ProductCode
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Product2.sObjectType;        
    }
}
/**
 * @File Name          : ContactsSelector.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 6/7/2020, 2:32:09 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/7/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class ContactsSelector extends fflib_SObjectSelector{
    public ContactsSelector() {
        super();
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Contact.Id,
            Contact.Name,
            Contact.Title,
            Contact.Phone,
            Contact.Email
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Contact.sObjectType;        
    }

    public List<Contact> selectSObjectsByAccountId(set<Id> accountIds){
        return (List<Contact>) Database.query(
          newQueryFactory(true)
            .setCondition('accountid IN : accountIds')
            .toSOQL()
        );
    }

    public List<Contact> selectSObjectsByFilter(String filterClause, list<Schema.SObjectField> sobjectFields){
        return (List<Contact>) Database.query(
          newQueryFactory(true)
            .setCondition(filterClause)
            .toSOQL()
        );
    }
}
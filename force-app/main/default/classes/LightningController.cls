/**
 * @File Name          : LightningController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 1/2/2020, 6:17:05 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/2/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class LightningController {
    @AuraEnabled
	public static list<Contact> getContacts(String ctrlAccountId, Integer intlimits, Integer intoffsets) {
	    return [Select Id, FirstName, LastName, Email, Phone, Account.name From Contact 
                Where AccountId =: ctrlAccountId order by FirstName /*Limit 10 Offset 5*/];
	}
    @AuraEnabled
	public static Integer getTotalCount(String ctrlAccountId) {
	    AggregateResult results = [Select count(Id) total from Contact Where AccountId =: ctrlAccountId];
        Integer total =(Integer)results.get('total') ; 
        return total;
	}
    @AuraEnabled
	public static List<Account> getAccounts() {
	   return [Select Id, Name From Account limit 10];
	}
    
    @AuraEnabled
    public static void saveContacts(List<Contact> ListContact, String accountId){
    	List<Contact> contactList = new List<Contact>();
    	list<Contact> dbContacts;
    	String accountIdStr = (String)accountId;
    	contactList.addAll((List<Contact>)ListContact);
    	set<String> idSet = new set<String>(); 
    	for(Contact conObj : contactList){
    		conObj.accountId = accountIdStr;
    		String contactId = (String)conObj.Id;
    		if(contactId <> null && contactId <> ''){
    			idSet.add(contactId);
    		}
    	}
        if(!idSet.isEmpty()){
        	dbContacts = [select id from Contact where accountId =: accountId AND id NOT in:idSet];
        }else{
        	dbContacts = [select id from Contact where accountId =: accountId];
        }
        
        if(!dbContacts.isEmpty()){
        	delete dbContacts;
        }

        if(!contactList.isEmpty()){
        	upsert contactList;
        }
    }
    
    @AuraEnabled
    public static list<Contact> updateContacts(List<Contact> listContact, String accountIdStr){
        system.debug('listContact : '+listContact);
        system.debug('accountIdStr : '+accountIdStr);
        for(Contact conObj: listContact){
            system.debug('conObj'+conObj);
            if(conObj.Id <> null && String.valueOf(conObj.Id).length() < 15){
                conObj.Id=null;
                conObj.AccountId = accountIdStr;
            }
        }
        system.debug('listContact : '+listContact);
        if(!listContact.isEmpty()){
            upsert listContact;
        }
        return getContacts(accountIdStr,10,5);
    }
    
    @AuraEnabled
    public static list<Contact> deleteContactsCtr(List<Contact> listContactDel,String accountIdStr){
        system.debug('listContactDel'+listContactDel);
        if(!listContactDel.isEmpty()){
            delete listContactDel;
        }
		return getContacts(accountIdStr,10,5);        
    }
}
/**
 * @description       : 
 * @author            : Dev Goyal
 * @group             : 
 * @last modified on  : 11-21-2020
 * @last modified by  : Dev Goyal
 * Modifications Log 
 * Ver   Date         Author      Modification
 * 1.0   11-05-2020   Dev Goyal   Initial Version
**/
public class AccountContactCtrl {
    @AuraEnabled
	public static list<Contact> getContacts(String ctrlAccountId) {
	    return [Select Id, FirstName, LastName, Email, Phone, Account.name From Contact 
                Where AccountId =: ctrlAccountId order by FirstName];
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
        return getContacts(accountIdStr);
    }
    
    @AuraEnabled
    public static list<Contact> deleteContactsCtr(List<Contact> listContactDel,String accountIdStr){
        system.debug('listContactDel'+listContactDel);
        if(!listContactDel.isEmpty()){
            delete listContactDel;
        }
		return getContacts(accountIdStr);        
    }

    @AuraEnabled
    public static list<Contact> deleteContact(Id contactId,String accountIdStr){
        system.debug('contactId'+contactId);
        if(contactId <> null){
            Database.delete(contactId);
        }
		return getContacts(accountIdStr);        
    }
}

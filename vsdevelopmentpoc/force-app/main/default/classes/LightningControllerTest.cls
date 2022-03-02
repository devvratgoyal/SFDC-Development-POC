/**
 * @File Name          : LightningControllerTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 1/6/2020, 2:43:32 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/1/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@IsTest
private class LightningControllerTest {
    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        List<Contact> testConts = new List<Contact>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i));
        }
        insert testAccts;
        for(Account accObj: testAccts){
            Contact conObj1 = new Contact(lastname = 'Test Contact', Accountid = accObj.Id);
            testConts.add(conObj1);
        }
        insert testConts;
    }
    
    @isTest static void TestGetContacts() {
        // Get the first test account by using a SOQL query
        Account acct = [SELECT Id FROM Account WHERE Name='TestAcct0' LIMIT 1];
        
        list<Contact> listContacts = LightningController.getContacts(acct.Id, 0, 0);
        System.assert(listContacts.size() == 1);
    }

    @isTest static void testGetTotalCount() {
        // Get the first account by using a SOQL query
        Account acct = [SELECT Id FROM Account WHERE Name='TestAcct0' LIMIT 1];
        // Perform some testing
        LightningController.getTotalCount(acct.Id);
    }

    @isTest static void testGetAccounts() {
        // Perform some testing
        List<Account> listAccounts = LightningController.getAccounts();
    }

    @isTest static void testUpdateContacts() {
        // Get the first account by using a SOQL query
        Account acct = [SELECT Id, (select id, firstname, lastname from Contacts) FROM Account WHERE Name='TestAcct0' LIMIT 1];
        // Perform some testing
        Integer i = 0;
        for(Contact conObj : acct.contacts){
            conObj.firstname = 'testfirstname'+i;
            conObj.lastname = 'testlastname'+i;
            i++;
        }
        List<Contact> listContacts = LightningController.updateContacts(acct.contacts, acct.Id);
    }
    
    @isTest static void testSaveContacts() {
        // Get the first account by using a SOQL query
        Account acct = [SELECT Id, (select id, firstname, lastname from Contacts) FROM Account WHERE Name='TestAcct0' LIMIT 1];
        // Perform some testing
        Integer i = 0;
        for(Contact conObj : acct.contacts){
            conObj.firstname = 'testfirstname'+i;
            conObj.lastname = 'testlastname'+i;
            i++;
        }
        LightningController.saveContacts(acct.contacts, acct.Id);
    }

    @isTest static void testSaveContacts1() {
        // Get the first account by using a SOQL query
        Account acct = [SELECT Id, (select id, firstname, lastname from Contacts) FROM Account WHERE Name='TestAcct0' LIMIT 1];
        // Perform some testing
        Integer i = 0;
        list<Contact> listCnts = new list<Contact>();
        for(Contact conObj : acct.contacts){
            conObj = new Contact();
            conObj.firstname = 'testfirstname'+i;
            conObj.lastname = 'testlastname'+i;
            conObj.AccountId = acct.Id;
            i++;
            listCnts.add(conObj);
        }
        LightningController.saveContacts(listCnts, acct.Id);
    }

    @isTest static void testDeleteContactsCtr() {
        // Get the first account by using a SOQL query
        Account acct = [SELECT Id, (select id from Contacts) FROM Account WHERE Name='TestAcct0' LIMIT 1];
        // Perform some testing
        LightningController.deleteContactsCtr(acct.contacts, acct.Id);
    }
}
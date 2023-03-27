/**
 * @File Name          : AccountsService.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 08-17-2022
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class AccountsService {
    public AccountsService() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunitiesByAccountId(Id accountId){
        //getAccountInHirarchy(accountId);
        return new OpportunitiesSelector().selectSObjectsByAccountId(new set<Id>{accountId});
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactListByAccountId(Id accountId) {
        return new ContactsSelector().selectSObjectsByAccountId(new set<Id>{accountId});
        
    }

    public map<Id,Account> getAccountInHirarchy(Id accountId){
        // return all accounts in hisrarchy
        return null;
    }

    public list<Account> calculateTotalCountFromOpportunities(Set<Id> accountIds){
        //List<Account> accountList = new AccountsSelector().selectAccountsWithOpportunities(accountIds);
        // update logic on account.
        return null;
    }
    
    public void selectAsset(){
        list<Asset> listAssets = [select id, Name, AssetLevel from Asset];
    }
}
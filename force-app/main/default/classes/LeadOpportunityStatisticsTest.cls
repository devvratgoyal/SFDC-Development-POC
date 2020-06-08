/**
 * @File Name          : LeadOpportunityStatisticsTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 4/28/2020, 8:53:16 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/27/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
private class LeadOpportunityStatisticsTest {
    
    static id adminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    static String OppyStage = 'Closed Won';

    @TestSetup
    static void setUp(){
        
        Lead leadObj;
        Opportunity Oppy;
        
        List<Lead> lstLead =   new List<Lead>{
            new Lead(Company = 'TestCompany1', LastName = 'Test1', Status = 'Open'),
            new Lead(Company = 'TestCompany2', LastName = 'Test2', Status = 'Open'),
            new Lead(Company = 'TestCompany3', LastName = 'Test3', Status = 'Open'),
            new Lead(Company = 'TestCompany4', LastName = 'Test4', Status = 'Open')
           };  
        insert lstLead;

        Opportunity closedWonOppy = createOpportunity(system.today(), OppyStage);
        Opportunity prospectingOppy = createOpportunity(null, '');

    }

    @isTest static void getStatisticsWithNoDateFilters(){
        Test.startTest();
        
        list<LeadOpportunityWrapper> listWrapper =  LeadOpportunityStatistics.getLeadOpportunity(null, null);
        system.assert(listWrapper.size()==1);
        system.assert(listWrapper[0].totalLeads == 4);
        system.assert(listWrapper[0].totalOpportunities == 1);
		system.assert(listWrapper[0].owner == 'Dev Vrat Goyal');
        
        Test.stopTest();
    }

    @isTest static void getStatisticsOppywithoutLeads(){
        Test.startTest();
        
        Date furureDate = system.today().addDays(5);
        
        list<LeadOpportunityWrapper> listWrapper =  LeadOpportunityStatistics.getLeadOpportunity(furureDate, furureDate);
        system.assert(listWrapper.size()==1);
        system.assert(listWrapper[0].totalLeads == 0);
        system.assert(listWrapper[0].totalOpportunities == 1);
		system.assert(listWrapper[0].owner == 'Dev Vrat Goyal');
        Test.stopTest();
    }

    @isTest static void getStatisticsLeadswithoutOppy(){
        Test.startTest();
        
        Date pastDate = system.today().addDays(-5);
        
        list<LeadOpportunityWrapper> listWrapper =  LeadOpportunityStatistics.getLeadOpportunity(pastDate, pastDate);
        system.assert(listWrapper.size()==1);
        system.assert(listWrapper[0].totalLeads == 4);
        system.assert(listWrapper[0].totalOpportunities == 0);
		system.assert(listWrapper[0].owner == 'Dev Vrat Goyal');
        Test.stopTest();
    }

    @isTest static void getStatisticsWithoutMatchingCritiria(){
        Test.startTest();
        
        Date furureDate = system.today().addDays(5);
        Date pastDate = system.today().addDays(-5);
        
        list<LeadOpportunityWrapper> listWrapper =  LeadOpportunityStatistics.getLeadOpportunity(furureDate, pastDate);
        system.assert(listWrapper.size()==0);
        Test.stopTest();
    }

    @isTest static void getStatisticsWithTwoOwners(){
        Test.startTest();
        
        Date todayDate = system.today();
        User user1 = createUser(adminId);
        list<Lead> leadsToUpdate = [select id from Lead limit 2];
        for(Lead leadObj: leadsToUpdate){
            leadObj.OwnerId = user1.Id;
        }
        update leadsToUpdate;

        list<Opportunity> oppyToUpdate = [select id from Opportunity where stageName = : OppyStage];
        for(Opportunity oppyObj : oppyToUpdate){
            oppyObj.ownerId = user1.Id;
        }
        update oppyToUpdate;
        
        list<LeadOpportunityWrapper> listWrapper =  LeadOpportunityStatistics.getLeadOpportunity(todayDate, todayDate);
        
        system.assert(listWrapper.size()==2);
        for(LeadOpportunityWrapper wrapperObj : listWrapper){
            system.assert(wrapperObj.totalLeads == 2);
            if(wrapperObj.owner == 'Dev Vrat Goyal'){
                system.assert(wrapperObj.totalOpportunities == 0);
            }else if(wrapperObj.owner == 'Last'){
                system.assert(wrapperObj.totalOpportunities == 1);
            }
        }
        
        Test.stopTest();
    }

    private static User createUser(Id userProfileId){

        User userObj = new User(LastName = 'Last', Email = 'test@salesforce.com', 
            Username = 'test@salesforce.com' + System.currentTimeMillis(), Title = 'title', Alias = 'alias', 
            TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = userProfileId );

        insert userObj;

        return userObj;
    }

    private static Opportunity createOpportunity(Date closeDate, String stageName){
       
        Opportunity opportunityToCreate = new Opportunity();
        
        // Populate dynamic fields?
        if(closeDate <> null){
            opportunityToCreate.CloseDate = closeDate;
        }else{
            opportunityToCreate.CloseDate = system.today();
        }
        if(stageName != ''){
            opportunityToCreate.StageName = stageName;
        }else{
            opportunityToCreate.StageName = 'Prospecting';
        }
        
        opportunityToCreate.Name = 'Test Opportunity';
        opportunityToCreate.LeadSource = 'Other';
        
        insert opportunityToCreate;

        return opportunityToCreate;
    }
}
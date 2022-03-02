trigger AddCampaignMembersForPage_Feeds on Facebook_Campaigns__c (after insert, after update) {
    list<Facebook_Feeds__c> facebookfeeds = new list<Facebook_Feeds__c> ();
    list<Facebook_Child_Feed__c> facebookChildfeeds = new list<Facebook_Child_Feed__c> ();
    list<CampaignMember> CampaignMem = new list<CampaignMember> ();
    list<CampaignMember> CampaignMemAlreadyExist = new list<CampaignMember> ();
    list<Contact> Contacts = new list<Contact> ();
    set<string> UserIDs = new set <string> ();
    set<string> FBPagesIDs = new set <string> ();
    set<string> AlreadyExistConIds = new set<string> ();
    list<string> ConIds = new list<string> ();
    set<string> facebookIds = new set <string> ();
    
    boolean executeTriggerFlag = false;
    
    if(trigger.isInsert && trigger.new[0].Add_Campaign_Members__c == 'yes') {
        executeTriggerFlag = true;
    }
    else if(trigger.isUpdate && trigger.new[0].Add_Campaign_Members__c == 'yes') {
        if(trigger.new[0].Add_Campaign_Members__c != trigger.oldmap.get(trigger.new[0].Id).Add_Campaign_Members__c && trigger.new[0].Add_Campaign_Members__c == 'yes') {
            executeTriggerFlag = true;
        }
        if(trigger.new[0].Facebook_Feed__c != trigger.oldmap.get(trigger.new[0].Id).Facebook_Feed__c && trigger.new[0].Facebook_Feed__c != null) {
            executeTriggerFlag = true;
        }
        else if(trigger.new[0].Facebook_Pages__c != trigger.oldmap.get(trigger.new[0].Id).Facebook_Pages__c && trigger.new[0].Facebook_Pages__c != null) {
            executeTriggerFlag = true;
        }
        else if(trigger.new[0].Duration_For_Campaign_Member__c != trigger.oldmap.get(trigger.new[0].Id).Duration_For_Campaign_Member__c && trigger.new[0].Duration_For_Campaign_Member__c != null) {
            executeTriggerFlag = true;
        }
        else if(trigger.new[0].From_Date__c != trigger.oldmap.get(trigger.new[0].Id).From_Date__c && trigger.new[0].From_Date__c != null) {
            executeTriggerFlag = true;
        }
        else {
            executeTriggerFlag = false;
        }
    }
    
    if(executeTriggerFlag && trigger.new[0].Facebook_Feed__c != null) {
        
        if(trigger.new[0].From_Date__c!=null && trigger.new[0].Duration_For_Campaign_Member__c=='From Specified Date') {
            
            facebookfeeds = [Select f.Id, f.Facebook_User_Account__c, f.Facebook_Page__c, f.External_ID__c, f.External_ID2__c, 
                            (Select Id, External_ID2__c From Facebook_Child_Feed__r
                                where CreatedDate > =: trigger.new[0].From_Date__c and isDeleted__c != true) 
                            From Facebook_Feeds__c f  
                            where //f.Recordtype.DeveloperName = 'Inbound' AND 
                            f.isDeleted__c != true AND f.Id = :trigger.new[0].Facebook_Feed__c  AND f.CreatedDate > =: trigger.new[0].From_Date__c
                            LIMIT : (limits.getLimitQueryRows() - limits.getQueryRows())];
            
        }
        else {
            facebookfeeds = [Select f.Id, f.Facebook_User_Account__c, f.Facebook_Page__c, f.External_ID__c, f.External_ID2__c, 
                            (Select Id, External_ID2__c From Facebook_Child_Feed__r where isDeleted__c != true) 
                            From Facebook_Feeds__c f  
                            where //f.Recordtype.DeveloperName = 'Inbound' AND 
                            f.isDeleted__c != true AND f.Id = :trigger.new[0].Facebook_Feed__c 
                            LIMIT : (limits.getLimitQueryRows() - limits.getQueryRows())];
        }
    } 
    
    else if(executeTriggerFlag && trigger.new[0].Facebook_Pages__c != null) {
        
        if(trigger.new[0].From_Date__c!=null && trigger.new[0].Duration_For_Campaign_Member__c=='From Specified Date') {
            facebookfeeds = [Select f.Id, f.Facebook_User_Account__c, f.Facebook_Page__c, f.External_ID__c, f.External_ID2__c, 
                            (Select Id, External_ID2__c From Facebook_Child_Feed__r 
                                where CreatedDate > =: trigger.new[0].From_Date__c and isDeleted__c != true) 
                            From Facebook_Feeds__c f  
                            where //f.Recordtype.DeveloperName = 'Inbound' AND 
                            f.isDeleted__c != true AND f.Facebook_Page__c = :trigger.new[0].Facebook_Pages__c AND f.CreatedDate > =: trigger.new[0].From_Date__c  
                            LIMIT : (limits.getLimitQueryRows() - limits.getQueryRows())];
        }
        else {
            facebookfeeds = [Select f.Id, f.Facebook_User_Account__c, f.Facebook_Page__c, f.External_ID__c, f.External_ID2__c, 
                            (Select Id, External_ID2__c From Facebook_Child_Feed__r where isDeleted__c != true) 
                            From Facebook_Feeds__c f  
                            where //f.Recordtype.DeveloperName = 'Inbound' AND 
                            f.isDeleted__c != true AND f.Facebook_Page__c = :trigger.new[0].Facebook_Pages__c 
                            LIMIT : (limits.getLimitQueryRows() - limits.getQueryRows())];
        }
    }
    
    if(!facebookfeeds.IsEmpty()) {
        for(Facebook_Feeds__c ff: facebookfeeds) {
            if(ff.External_ID2__c != null && ff.External_ID2__c != '') {
                facebookIds.add(ff.External_ID2__c);
            }
            for(Facebook_Child_Feed__c ffChild:ff.Facebook_Child_Feed__r) {
                if(ffChild.External_ID2__c != null && ffChild.External_ID2__c != '') {
                    facebookIds.add(ffChild.External_ID2__c);
                }
            }
        }
        map<Id, Contact> contactMap = new map<Id, Contact>([Select Id, Account.FacebookID__c, AccountId 
                                    From Contact  
                                    where Account.FacebookID__c in :facebookIds 
                                    LIMIT : (limits.getLimitQueryRows() - limits.getQueryRows())]);
        if(contactMap != null && !contactMap.isEmpty()) {
            CampaignMemAlreadyExist = [Select ContactId, CampaignId 
                                    From CampaignMember 
                                    where ContactId In: contactMap.keySet() 
                                    and CampaignId=:trigger.new[0].Campaign__c 
                                    LIMIT : (limits.getLimitQueryRows() - limits.getQueryRows())];
            if(CampaignMemAlreadyExist.IsEmpty())
            {
                for(Contact c: contactMap.values())
                {
                    CampaignMember cm = new CampaignMember();
                    cm.campaignid = trigger.new[0].Campaign__c;
                    cm.ContactId = c.id;
                    CampaignMem.add(cm);
                }
            }
            else {
                
                for(CampaignMember cm: CampaignMemAlreadyExist)
                {
                    AlreadyExistConIds.add(cm.ContactId );
                    contactMap.remove(cm.ContactId);
                }
                
                for(Contact c: contactMap.values())
                {
                    CampaignMember cm = new CampaignMember();
                    cm.campaignid = trigger.new[0].Campaign__c;
                    cm.ContactId = c.id;
                    CampaignMem.add(cm);
                }
                    
                
            }
            
            
        }
        if(!CampaignMem.IsEmpty())
        {
            insert CampaignMem; 
        }
    }
}
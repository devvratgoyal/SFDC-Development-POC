trigger InboundOutboundTotalCount on Facebook_Feeds__c (after insert,after update,after delete, after undelete) {
    
    Map<Id, Id> mapFacebookPages = new Map<Id, Id>();
    
    map<Id, Recordtype> recordtypeMap = new map<Id,Recordtype>([Select Id, DeveloperName from Recordtype where DeveloperName in ('Inbound','Outbound') AND sObjectType = 'Facebook_Feeds__c']);
    
    
    
    //If Delete event execute Trigger.
    if(Trigger.isDelete) {
        //Loop through Batch of records for Delete Event.
        for(Facebook_Feeds__c c : Trigger.old){
            //Put Account Id as key and value in accountMap.
            if(recordtypeMap.size() > 0 && c.RecordTypeId != null && recordtypeMap.get(c.RecordTypeId) != null &&  (recordtypeMap.get(c.RecordTypeId).DeveloperName =='Inbound' || (recordtypeMap.get(c.RecordTypeId).DeveloperName == 'Outbound' && c.External_ID__c != null)))
            {
                mapFacebookPages.put(c.Facebook_Page__c, c.Facebook_Page__c);
            }
        }
    }
    //Else loop i.e. Insert, Update or Undelete executed the Trigger.
    else {
        //Loop through Batch of records.
        for(Facebook_Feeds__c c : Trigger.new){
            //Check if Account Id is updated.
            if(Trigger.isUpdate) {
                if(Trigger.oldMap.get(c.Id).IsDeleted__c != c.IsDeleted__c || Trigger.oldMap.get(c.Id).External_ID__c != c.External_ID__c || Trigger.oldMap.get(c.Id).Facebook_Page__c != c.Facebook_Page__c) {
                    //Check If old Account Id was not null.
                    if(Trigger.oldMap.get(c.Id).Facebook_Page__c != null ) {
                        //Put old Account Id as key and value in accountMap.
                        if(Trigger.oldMap.get(c.Id).RecordTypeId != null && recordtypeMap.get(Trigger.oldMap.get(c.Id).RecordTypeId) != null && (recordtypeMap.get(Trigger.oldMap.get(c.Id).RecordTypeId).DeveloperName =='Inbound' || (recordtypeMap.get(Trigger.oldMap.get(c.Id).RecordTypeId).DeveloperName == 'Outbound' && Trigger.oldMap.get(c.Id).External_ID__c != null)))
                        {
                            mapFacebookPages.put(Trigger.oldMap.get(c.Id).Facebook_Page__c, Trigger.oldMap.get(c.Id).Facebook_Page__c);
                        }
                    }
                    //Check if new Account Id is not null.
                    if(c.Facebook_Page__c != null) {
                        //Put new Account Id as key and value in accountMap.
                        if(recordtypeMap.size() > 0 && c.RecordTypeId != null && recordtypeMap.get(c.RecordTypeId) != null && (recordtypeMap.get(c.RecordTypeId).DeveloperName =='Inbound' || (recordtypeMap.get(c.RecordTypeId).DeveloperName == 'Outbound' && c.External_ID__c != null)))
                        {
                            mapFacebookPages.put(c.Facebook_Page__c, c.Facebook_Page__c);
                        }
                    }
                }
            }
            //Else loop.
            else {
                //Put Account Id as key and value in accountMap.
                if(recordtypeMap.size() > 0 && c.RecordTypeId != null && recordtypeMap.get(c.RecordTypeId) != null && (recordtypeMap.get(c.RecordTypeId).DeveloperName =='Inbound' || (recordtypeMap.get(c.RecordTypeId).DeveloperName == 'Outbound' && c.External_ID__c != null)))
                {
                    mapFacebookPages.put(c.Facebook_Page__c, c.Facebook_Page__c);
                }
            }
        }
    }
    
    //Check if accountMap is not empty.
    if(!mapFacebookPages.isEmpty()) {
        //Get Account Id and Count in AggregateResult list group by Account Id and Account id in accountMap keyset.
        Integer inboundCount;
        Integer outboundCount;
        
        list<Facebook_Pages__c> facebookPagesList = [Select f.Total_Number_Of_Feed__c,f.id,f.Number_Of_Outbound_Messages__c, f.Number_Of_Inbound_Messages__c,
                                                (select c.Id,c.RecordTypeId,c.RecordType.DeveloperName,c.IsDeleted__c,c.External_ID__c 
                                                from facebook_feeds__r c 
                                                where (c.IsDeleted__c != true AND (c.RecordType.DeveloperName ='Inbound' OR (c.RecordType.DeveloperName = 'Outbound' AND c.External_ID__c != null))
                                                )  ) 
                                                From Facebook_Pages__c f where f.id in : mapFacebookPages.keySet() 
                                                LIMIT : (Limits.getLimitQueryRows() - Limits.getQueryRows())];
        
        
        list<Facebook_Pages__c> facebookPagesListToUpdate = new list<Facebook_Pages__c>();
        
        for(Facebook_Pages__c page : facebookPagesList)
        {
            inboundCount=0;
            outboundCount=0;

            for(Facebook_Feeds__c feed : page.facebook_feeds__r)
            {
                
                    if(feed.RecordType.DeveloperName=='Inbound')
                        inboundCount+=1;
                    else if(feed.RecordType.DeveloperName=='Outbound')
                        outboundCount+=1;
                
            }
            
            page.Number_Of_Inbound_Messages__c = inboundCount;
            page.Number_Of_Outbound_Messages__c = outboundCount;
            page.Total_Number_Of_Feed__c = inboundCount+outboundCount;
            facebookPagesListToUpdate.add(page);
        }
         
        //Check if accountList is not empty.
        if(!facebookPagesListToUpdate.isEmpty()) {
            //Update accountList for Contact Count field.
            system.debug('facebookPagesListToUpdate ----> ' + facebookPagesListToUpdate);
            update facebookPagesListToUpdate;
        }
    }
    
}
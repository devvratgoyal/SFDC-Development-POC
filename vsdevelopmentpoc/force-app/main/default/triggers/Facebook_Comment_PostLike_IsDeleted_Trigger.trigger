/*
Company : Fujitsu America
Date : August 25,2012
Author : Rohit Sen
Description : This trigger is on Facebook Feed Object and will be fired after update of every Feed record 
              when isDeleted field is set to TRUE. It will mark the isDeleted field of all its related child field to true
History :
*/ 



trigger Facebook_Comment_PostLike_IsDeleted_Trigger on Facebook_Feeds__c (after update) 
{
    Map<String,Facebook_Feeds__c> feedObjectToUpdateMap = new Map<String,Facebook_Feeds__c>(); //map contains Facebook Id of feed as key and its corresponding Feed Obj 
    List<Facebook_Child_Feed__c> childFeedObjectQueryList = new List<Facebook_Child_Feed__c>();
    List<Facebook_Child_Feed__c> childFeedObjectUpdateList = new List<Facebook_Child_Feed__c>();
    
    if(Trigger.isAfter)
    {
        system.debug('Rohit Test 1.............');
        if(Trigger.isUpdate)
        {           
            system.debug('Rohit Test 2.............');
            
            for(Facebook_Feeds__c feedChild : Trigger.new)
            {
                system.debug('Rohit Test 3.............');
                system.debug(feedChild +' .........Output.............'+Trigger.oldmap.get(feedChild.id));
                if(feedChild.IsDeleted__c == true)
                {
                    system.debug('Rohit Test 4.............');
                    feedObjectToUpdateMap.put(feedChild.Id,feedChild);
                }
            }   
            
            system.debug(feedObjectToUpdateMap.keySet()+' <<<<<<<<<<<< feedObjectToUpdateMap >>>>>>>>>>>>>>> '+feedObjectToUpdateMap);
            childFeedObjectQueryList = [select Id,IsDeleted__c from Facebook_Child_Feed__c where Facebook_Feed__c IN : feedObjectToUpdateMap.keySet()];
            system.debug(childFeedObjectQueryList.size()+' ............... childFeedObjectQueryList >>>>>>>>>> '+childFeedObjectQueryList);
            
            for(Facebook_Child_Feed__c childtoUpdate : childFeedObjectQueryList)
            {
                if(childtoUpdate.IsDeleted__c == false)
                {
                    childtoUpdate.IsDeleted__c = true;
                    childFeedObjectUpdateList.add(childtoUpdate);
                }
            }
            system.debug(childFeedObjectUpdateList.size()+'............... childFeedObjectUpdateList.size() >>>>>>>>>>>>>>>'+childFeedObjectUpdateList.size());
            if(childFeedObjectUpdateList.size() > 0)
            {
                update childFeedObjectUpdateList;
            }   
        
        }
    }
    
    
    
    

}
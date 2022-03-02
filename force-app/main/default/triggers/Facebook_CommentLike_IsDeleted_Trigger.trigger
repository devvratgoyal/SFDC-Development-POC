/*
Company : Fujitsu America
Date : August 25,2012
Author : Rohit Sen
Description : This trigger is on Facebook Child Feed Object and will be fired after update of every Child Feed record 
              when isDeleted field is set to TRUE. It will mark the isDeleted field of all its related child field to true.
History :
*/ 

trigger Facebook_CommentLike_IsDeleted_Trigger on Facebook_Child_Feed__c (after update) 
{
    Map<String,Facebook_Child_Feed__c> childfeedObjectToUpdateMap = new Map<String,Facebook_Child_Feed__c>(); //map contains Facebook Id of child feed as key and its corresponding ChildFeed Obj   
    List<Facebook_Child_Feed__c> childFeedObjectQueryList1 = new List<Facebook_Child_Feed__c>();
    List<Facebook_Child_Feed__c> childFeedObjectUpdateList1 = new List<Facebook_Child_Feed__c>();
    
    if(Trigger.isAfter)
    {
        system.debug('Rohit Test child 1.............');
        if(Trigger.isUpdate)
        {           
            system.debug('Rohit Test child 2.............');
            system.debug(Trigger.old+' ......... Trigger.old >>>>>>>>>>>>>>>'+Trigger.new);
            
            for(Facebook_Child_Feed__c childFeed : Trigger.new)
            {
                system.debug('Rohit Test child 3.............');
                system.debug(childFeed +' .........Output.............'+Trigger.old);
                if(childFeed.IsDeleted__c == true)
                {
                    system.debug('Rohit Test child 4.............');
                    childfeedObjectToUpdateMap.put(childFeed.External_ID__c,childFeed);
                }
            }   
            
            system.debug(childfeedObjectToUpdateMap.keySet()+' <<<<<<<<<<<< childfeedObjectToUpdateMap >>>>>>>>>>>>>>> '+childfeedObjectToUpdateMap);
            childFeedObjectQueryList1 = [select Id,IsDeleted__c from Facebook_Child_Feed__c where Feed_Type__c = 'Comment Like' AND External_ID__c IN : childfeedObjectToUpdateMap.keySet()];
            system.debug(childFeedObjectQueryList1.size()+' ............... childFeedObjectQueryList1 >>>>>>>>>> '+childFeedObjectQueryList1);
            
            for(Facebook_Child_Feed__c childtoUpdate : childFeedObjectQueryList1)
            {
                if(childtoUpdate.IsDeleted__c == false)
                {
                    childtoUpdate.IsDeleted__c = true;
                    childFeedObjectUpdateList1.add(childtoUpdate);
                }
            }
            system.debug(childFeedObjectUpdateList1.size()+'............... childFeedObjectUpdateList1.size() >>>>>>>>>>>>>>>'+childFeedObjectUpdateList1.size());
            if(childFeedObjectUpdateList1.size() > 0)
            {
                update childFeedObjectUpdateList1;
            }   
            
            
            
        }
    }
    

}
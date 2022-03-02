trigger BatchApexErrorTrigger on BatchApexErrorEvent (after insert) {
    
    list<BatchLeadConvertErrors__c> bcr= new List<BatchLeadConvertErrors__c>();
   
    for(BatchApexErrorEvent event: trigger.new){
       
        BatchLeadConvertErrors__c  evrterror= new BatchLeadConvertErrors__c ();
       
        evrterror.AsyncApexJobId__c= event.AsyncApexJobId;
        evrterror.Records__c=event.JobScope;
        evrterror.StackTrace__c=event.StackTrace;   
        bcr.add(evrterror);   
    }
   
    if(bcr.size()>0){
       
        insert bcr;
    }

}
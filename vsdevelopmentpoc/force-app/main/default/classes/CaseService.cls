public with sharing class CaseService {
   public static void closeCases(Set<Id> caseIds, String closeReason) {
       
       if(caseIds==null || caseIds.size()==0)
            throw new CaseServiceException('Cases not specified.');
        if(closeReason == '')
            throw new CaseServiceException('Invalid close reason.');
 
       List<Case> casetoClose = new List<Case>();
       Case caseObj;
       for(Id caseId : caseIds){
           caseObj = new Case(Id = caseId, Status = 'Closed', Reason=closeReason);
           casetoClose.add(caseObj);
       }
       
       if(!casetoClose.isEmpty()){
           SavePoint sp = Database.setSavePoint();
           try {
                update casetoClose;
           } catch (Exception e) {
                // Rollback
                Database.rollback(sp);
                // Throw exception on to caller
                throw e;
           } 
       }
   }
   
   public class CaseServiceException extends Exception {}
}
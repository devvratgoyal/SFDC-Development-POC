global class MergeUtilityBatch implements Database.Batchable<sObject>{
	
	global final String mergeType;
    global final boolean isInsert;
    global final boolean isUpdate;
	
	public class MergeUtilityBatchException extends Exception {}
	
	global MergeUtilityBatch(String mergeType, boolean isUpdate, boolean isInsert){
		this.mergeType = mergeType;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
	}
	
	global List<sObject> start(Database.BatchableContext BC){
		MergeUtility_Switch__c switchMU = MergeUtility_Switch__c.getOrgDefaults();
		if(!switchMU.Switch__c){
			return new List<sObject>();
		}
		String query = 'Select m.To_Id__c, m.Status__c, m.Retry__c, m.Merge_Type__c, m.Id, m.From_Id__c, m.Error__c From Merge_Id__c m where m.Merge_Type__c = \''+mergeType+
							'\' AND (m.Status__c = \'New\' OR m.Retry__c = true)';
		system.debug('query' +query);
		List<sObject> listSobjects= Database.query(query);
		if(listSobjects == null || listSobjects.isEmpty()){
			throw new MergeUtilityBatchException('No record found for this merge type : ' + mergeType);
		}
		return listSobjects;
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		list<Merge_Id__c> listMergeIds = (list<Merge_Id__c>) scope;
		
		map<Id, Id> mapFromToId = new map<Id, Id>();
		String fieldType;
		
		if(listMergeIds <> null && !listMergeIds.isEmpty()){
			fieldType = listMergeIds[0].Merge_Type__c;
		}
		
		for(Merge_Id__c mergeIdObj : listMergeIds){
			mapFromToId.put(mergeIdObj.From_Id__c, mergeIdObj.To_Id__c);
     	}
     	
     	if(fieldType <> '' && !mapFromToId.isEmpty()){
     		MergeUtility mergeUtilityObj = new MergeUtility();
     		mergeUtilityObj.replaceLookup(fieldType, mapFromToId, isUpdate, isInsert);
     	}
     }

	global void finish(Database.BatchableContext BC){
	
	}
}
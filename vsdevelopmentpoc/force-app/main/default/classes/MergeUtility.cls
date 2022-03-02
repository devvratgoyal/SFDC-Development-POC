public with sharing class MergeUtility{
    
    public class mergeException extends Exception {}
    
    public Map<String, Schema.SObjectType> globalDesc = Schema.getGlobalDescribe();
    
    public void replaceLookup(String fieldType, map<Id, Id> mapFromToId, boolean isUpdate, boolean isInsert){
        map<String, list<String>> objectFieldmap = new map<String, list<String>>();
        map<String, boolean> objectCloneFlagmap = new map<String, boolean>();
        String queryStr = 'select id, Name, Field_API_Name__c, Object_API_Name__c, Clone__c from MU_FieldConfiguration__c'+
                               ' where Merge_Type__c = \''+fieldType+'\'';
        if(isUpdate && !isInsert){
            queryStr += ' AND Clone__c = false';
        }else if(isInsert && !isUpdate){
            queryStr += ' AND Clone__c = true';
        }
        
        system.debug('queryStr : '+queryStr);
        
        List<MU_FieldConfiguration__c> mergeUtilityFieldMapping = Database.query(queryStr);
            
        if(mergeUtilityFieldMapping.isEmpty()){
            throw new mergeException('No field Mapping found for the specified fieldType.');
            return;
        }
        
        if(mapFromToId == null || mapFromToId.isEmpty()){
            throw new mergeException('Map for replacing ids cannot be blank or null (Key= From Id, Value= To Id).');
            return;
        }                                                                   
                                                                            
        for(MU_FieldConfiguration__c fieldMappingObj : mergeUtilityFieldMapping){
            if(objectFieldmap.containsKey(fieldMappingObj.Object_API_Name__c)){
                list<String> listFiledAPINames = objectFieldmap.get(fieldMappingObj.Object_API_Name__c);
                listFiledAPINames.add((String)fieldMappingObj.Field_API_Name__c);
                objectFieldmap.put(fieldMappingObj.Object_API_Name__c, listFiledAPINames);
            }else{
            	objectCloneFlagmap.put(fieldMappingObj.Object_API_Name__c, fieldMappingObj.Clone__c);
                objectFieldmap.put(fieldMappingObj.Object_API_Name__c, new list<String>{fieldMappingObj.Field_API_Name__c});
            }
        }
        //system.debug('objectFieldmap1 : '+objectFieldmap);
        
        for(String objectAPIName : objectFieldmap.keySet()){
            replaceLookupMain(objectAPIName, objectFieldmap.get(objectAPIName), mapFromToId, objectCloneFlagmap.get(objectAPIName));
            system.debug('objectAPIName :'+objectAPIName);
        }
        
    }
    
    private void replaceLookupMain(String objectAPIName, list<String> listFieldAPIName, map<Id, Id> mapFromToId, boolean isClone){
        
        String queryFields = '';
        String whereClause = '';
        list<Id> listFromIdList = new list<Id>();
        map<Id, String> mapRecordIdFromToId = new map<Id, String>();
        list<String> listReplaceFields = new list<String>();
        list<Merge_Log__c> listMergeLog = new list<Merge_Log__c>();
        Merge_Log__c mergeLogObj;
        
        listFromIdList.addAll(mapFromToId.keyset());
        
        String inValueString = '(\''+String.join(listFromIdList, '\', \'')+'\')';
        
        for(String fieldAPIName : listFieldAPIName){
            if(whereClause == ''){
                whereClause = fieldAPIName + ' IN ' + inValueString;
            }else{
                whereClause += ' OR ' + fieldAPIName + ' IN ' + inValueString;
            }
        }
        listFieldAPIName.add('Id');
        
        if(objectAPIName <> null && (objectAPIName.equalsIgnoreCase('Event'))){
        	whereClause += ' AND isChild = false';	
        }
        
        if(isClone){
        	listReplaceFields.addAll(listFieldAPIName);
        	listFieldAPIName.clear();
        	for(Schema.SobjectField strFld : globalDesc.get(objectAPIName).getDescribe().fields.getMap().Values()){
	        	DescribeFieldResult fieldDescribeResultObj = strFld.getDescribe();
	        	listFieldAPIName.add(fieldDescribeResultObj.getName());
        	}
        }
        
        String queryStr = 'select '+ String.join(listFieldAPIName, ', ') + ' from '+objectAPIName + ' where ' + whereClause;
        
        System.debug('queryStr : '+queryStr);
        
        list<sObject> queryResult = Database.query(queryStr);
        map<String, sObject> mapQueryResult = new map<String, sObject>(queryResult);
        
        list<sObject> listSObject;
        
        if(isClone){
        	listSObject = queryResult.deepClone(false,false,false);
        	handleClone(mapQueryResult, listReplaceFields, mapFromToId, mapRecordIdFromToId, objectAPIName);
        }else{
        	listSObject = queryResult;
        
	    	if(listSObject<> null && !listSObject.isEmpty()){
		        for(sObject obj : listSObject){
		            for(String fieldName : listFieldAPIName){
		                if(obj.get(fieldName) <> null && mapFromToId.containsKey((ID)obj.get(fieldName))){
		                    mapRecordIdFromToId.put((String)obj.get('Id'), (String)obj.get(fieldName) +'@@@@@'+ mapFromToId.get((ID)obj.get(fieldName)));
		                    obj.put(fieldName, mapFromToId.get((ID)obj.get(fieldName)));
		                }
		            }
		        }
		        
		        System.debug('mapRecordIdFromToId:('+mapRecordIdFromToId.SIZE()+ '): '+mapRecordIdFromToId+' :: listSObject:('+listSObject.SIZE()+'): '+listSObject);
		        list<Database.SaveResult> listSaveResults;
		        try{
		        		listSaveResults = Database.update(listSObject, false);
		        }catch(System.AsyncException e){
		        	system.debug('Exception occured : '+e);
		        }catch(Exception ex){
		        	system.debug('Exception occured : '+ex);
		        }
		        system.debug('listSaveResults : '+listSaveResults);
		        if(listSaveResults <> null){
			        for(Integer i=0; i< listSObject.size();i++){
			        	Database.SaveResult saveResultObj = listSaveResults[i];
			    		String[] fromToId = mapRecordIdFromToId.get((Id)listSObject[i].get('Id')).split('@@@@@');
			    		//system.debug('listSObject id : '+listSObject[i].get('Id')+' :: mapRecordIdFromToId.get(saveResultObj.getId()) : '+mapRecordIdFromToId.get((Id)listSObject[i].get('Id')));
			    		system.debug('SaveResultObj.isSuccess() : '+saveResultObj.isSuccess()+ ' : record Id : '+listSObject[i].get('Id') + ' : fromToId : '+fromToId[0] +' : ToId : '+fromToId[1]);
			        	mergeLogObj = new Merge_Log__c(RecordId__c = (String)listSObject[i].get('Id'), From_Id__c = fromToId[0], To_Id__c = fromToId[1], isSuccess__c = saveResultObj.isSuccess(), Error_Message__c = '', Merge_Object__c = objectAPIName);
			        	if(!saveResultObj.isSuccess()){
			        		for(Database.Error error : saveResultObj.getErrors()){
			        			mergeLogObj.Error_Message__c += error.getStatusCode()+'['+String.join(error.getFields(),',')+']'+error.getMessage();
			        		}
			        		system.debug('saveResultObj.getErrors() :'+saveResultObj.getErrors());
			        	}
			        	listMergeLog.add(mergeLogObj);
			        }
		        }
	    	}
	    	if(listMergeLog <> null && !listMergeLog.isEmpty()){
	    		insert listMergeLog;
	    	}
        }
    }
    
    private void handleClone(map<String, sObject> mapQueryResult, list<String> listReplaceFields, map<Id, Id> mapFromToId, map<Id, String> mapRecordIdFromToId, String objectAPIName){
    	list<Merge_Log__c> listMergeLog = new list<Merge_Log__c>();
    	Merge_Log__c mergeLogObj;
    	list<String> oldRecordIds = new list<String>();
    	list<sObject> oldSObjectList, newSObjectList;
    	if(mapQueryResult <> null && !mapQueryResult.isEmpty()){
    		oldRecordIds.addAll(mapQueryResult.keySet());
    		oldSObjectList = mapQueryResult.values();
    		newSObjectList = oldSObjectList.deepClone(false, false, false);
	        for(integer i = 0; i< newSObjectList.size(); i++){
	            for(String fieldName : listReplaceFields){
	                system.debug('obj : '+newSObjectList[i]+' fieldName : '+fieldName+' newSObjectList[i].get(fieldName) :'+newSObjectList[i].get(fieldName));
	                if(newSObjectList[i].get(fieldName) <> null && mapFromToId.containsKey((ID)newSObjectList[i].get(fieldName))){
	                    mapRecordIdFromToId.put((String)oldSObjectList[i].get('Id'), (String)newSObjectList[i].get(fieldName) +'@@@@@'+ mapFromToId.get((ID)newSObjectList[i].get(fieldName)));
	                    newSObjectList[i].put(fieldName, mapFromToId.get((ID)newSObjectList[i].get(fieldName)));
	                }
	            }
	        }
	        
	        System.debug('mapRecordIdFromToId:('+mapRecordIdFromToId.SIZE()+ '): '+mapRecordIdFromToId+' :: newSObjectList:('+newSObjectList.SIZE()+'): '+newSObjectList);
	        list<Database.SaveResult> listSaveResults;
	        try{
	        		listSaveResults = Database.insert(newSObjectList, false);
	        }catch(System.AsyncException e){
	        	system.debug('Exception occured : '+e);
	        }catch(Exception ex){
	        	system.debug('Exception occured : '+ex);
	        }
	        system.debug('listSaveResults : '+listSaveResults);
	        if(listSaveResults <> null){
		        for(Integer i=0; i< newSObjectList.size();i++){
		        	Database.SaveResult saveResultObj = listSaveResults[i];
		    		String[] fromToId = mapRecordIdFromToId.get(oldRecordIds[i]).split('@@@@@');
		    		system.debug('SaveResultObj.isSuccess() : '+saveResultObj.isSuccess()+ ' : old record Id : '+oldRecordIds + ' : new record Id : '+saveResultObj.getId() + ' : fromToId : '+fromToId +' : ToId : '+fromToId);
		        	mergeLogObj = new Merge_Log__c(From_Id__c = fromToId[0], To_Id__c = fromToId[1], isSuccess__c = saveResultObj.isSuccess(), Error_Message__c = '', IsClone__c = true, Merge_Object__c = objectAPIName);
		        	if(!saveResultObj.isSuccess()){
		        		for(Database.Error error : saveResultObj.getErrors()){
		        			mergeLogObj.Error_Message__c += error.getStatusCode()+'['+String.join(error.getFields(),',')+']'+error.getMessage();
		        		}
		        		mergeLogObj.Old_Record_Id__c = oldRecordIds[i];
		        		system.debug('saveResultObj.getErrors() :'+saveResultObj.getErrors());
		        	}else{
		        		mergeLogObj.RecordId__c = saveResultObj.getId();
		        		mergeLogObj.Old_Record_Id__c = oldRecordIds[i];
		        	}
		        	listMergeLog.add(mergeLogObj);
		        }
	        }
    	}
    	if(listMergeLog <> null && !listMergeLog.isEmpty()){
    		insert listMergeLog;
    	}
    }
    
    /*private void saveAttachment(Boolean isSuccess, String objectAPIName, Id fromId, Id toId, String body){
		  
		Attachment attachment = new Attachment();
		attachment.Body = Blob.valueOf('\n\t\t\t'+body);
		if(isSuccess){
			attachment.Name = String.valueOf('Success_'+objectAPIName+'_for_'+fromId+'_'+system.now()+'.txt');
		}else{
			attachment.Name = String.valueOf('Failure_'+objectAPIName+'_for_'+fromId+'_'+system.now()+'.txt');
		}
		attachment.ParentId = fromId; 
		insert attachment;
	}*/
	
	private Boolean validateId(String Idparam){
        String id = String.escapeSingleQuotes(Idparam);
        if((id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            return true;
        }
        return false;
    }
}
public with sharing class MergeMaster {
	
	public class mergeException extends Exception {}
	
	public String fieldType{get;set;}
	public string fileName{get;set;}
	public Blob fileContent{get;set;}
	
	public void replaceLookup(){
		String[] filelines = fileContent.toString().split('\n');
		map<String, String> mapFromToId = new map<String, String>();
		
		for (Integer i=1;i<filelines.size();i++){
            String[] inputvalues = new String[]{};
            inputvalues = filelines[i].split(',');
            if(inputvalues <> null && inputvalues.size()>1){
            	mapFromToId.put(inputvalues[0], inputvalues[1]);
            }
        }
        
        if(fieldType == null || fieldType.trim() == ''){
			throw new mergeException('FieldType is mandatory.');
			return;
		}
		
		if(mapFromToId == null || mapFromToId.isEmpty()){
			throw new mergeException('Attached file does not have proper data for From/To Id(Key= From Id, Value= To Id).');
			return;
		}
                
        System.debug('fieldType : '+fieldType+' fileName : '+fileName+' mapFromToId : '+mapFromToId);
	}
	
	public static Map<String, List<String>> getObjectReferences(String objectName){
     	
     	Map<String, List<String>> mapObjectReferences = new Map<String, List<String>>();
     	Map<String, Schema.SObjectType> globalDesc = Schema.getGlobalDescribe();
     	
     	for(Schema.SObjectType sObjType : globalDesc.values()){
     		for(Schema.SobjectField strFld: sObjType.getDescribe().fields.getMap().Values()){
     			Schema.DescribeFieldResult fieldDescribe = strFld.getDescribe();
     			if(fieldDescribe.getType() == Schema.DisplayType.REFERENCE){
     				for(Schema.sObjectType sObjectTypeObj : fieldDescribe.getReferenceTo()){
	     				if(sObjectTypeObj == globalDesc.get(objectName)){
	     					if(!mapObjectReferences.containsKey(sObjType.getDescribe().getName())){
	     						mapObjectReferences.put(sObjType.getDescribe().getName(), new list<String>{strFld.getDescribe().getName()});
	     					}else{
	     						list<String> listFieldAPIs = (list<String>)mapObjectReferences.get(sObjType.getDescribe().getName());
	     						listFieldAPIs.add((String)strFld.getDescribe().getName());
	     						mapObjectReferences.put(sObjType.getDescribe().getName(), listFieldAPIs);
	     					}
	     				}
     				}
     			}
     		}
     	}
     	
     	return mapObjectReferences;
     }
	
	public void replaceLookup(String fieldType, map<Id, Id> mapFromToId){
		map<String, list<String>> objectFieldmap = new map<String, list<String>>();
		List<MergeUtility_FieldConfig__c> mergeUtilityFieldMapping = [select id, Name, Field_API_Name__c, Object_API_Name__c from MergeUtility_FieldConfig__c 
																			where Clone__c = false AND Merge_Type__c =: fieldType];
		
		if(mergeUtilityFieldMapping.isEmpty()){
			throw new mergeException('No field Mapping found for the specified fieldType.');
			return;
		}
		
		if(mapFromToId == null || mapFromToId.isEmpty()){
			throw new mergeException('Map for replacing ids cannot be blank or null (Key= From Id, Value= To Id).');
			return;
		}																	
																			
		for(MergeUtility_FieldConfig__c fieldMappingObj : mergeUtilityFieldMapping){
			if(objectFieldmap.containsKey(fieldMappingObj.Object_API_Name__c)){
				list<String> listLocStr = objectFieldmap.get(fieldMappingObj.Object_API_Name__c);
				listLocStr.add((String)fieldMappingObj.Field_API_Name__c);
				objectFieldmap.put(fieldMappingObj.Object_API_Name__c, listLocStr);
			}else{
				objectFieldmap.put(fieldMappingObj.Object_API_Name__c, new list<String>{fieldMappingObj.Field_API_Name__c});
			}
		}
		system.debug('objectFieldmap1 : '+objectFieldmap);
		
		for(String objectAPIName : objectFieldmap.keySet()){
			replaceLookup(objectAPIName, objectFieldmap.get(objectAPIName), mapFromToId);
		}
		
	}
	
	private void replaceLookup(String objectAPIName, list<String> listFieldAPIName, map<Id, Id> mapFromToId){
		
		String queryFields = '';
		String whereClause = '';
		
		list<Id> listFromIdList = new list<Id>();
		listFromIdList.addAll(mapFromToId.keyset());
		
		String inValueString = '(\''+String.join(listFromIdList, '\', ')+'\')';
		
		for(String fieldAPIName : listFieldAPIName){
			if(whereClause == ''){
				whereClause = fieldAPIName + ' IN ' + inValueString;
			}else{
				whereClause += ' OR ' + fieldAPIName + ' IN ' + inValueString;
			}
		}
		
		String queryStr = 'select '+ String.join(listFieldAPIName, ', ') + ' from '+objectAPIName + ' where ' + whereClause;
		
		System.debug(queryStr);
		
		list<sObject> listSObject = Database.query(queryStr);
		
		for(sObject obj : listSObject){
			for(String fieldName : listFieldAPIName){
				if(obj.get(fieldName) <> null && mapFromToId.containsKey((ID)obj.get(fieldName))){
					obj.put(fieldName, mapFromToId.get((ID)obj.get(fieldName)));
				}
			}
		}
		
		System.debug('listSObject : '+listSObject);
		
		update listSObject;
	}
	
	public void replaceLookup(String fieldType, String fromId, String toId){
		map<String, list<String>> objectFieldmap = new map<String, list<String>>();
		List<MergeUtility_FieldConfig__c> mergeUtilityFieldMapping = [select id, Name, Field_API_Name__c, Object_API_Name__c from MergeUtility_FieldConfig__c 
																			where Clone__c = false AND Merge_Type__c =: fieldType];
		
		if(mergeUtilityFieldMapping.isEmpty()){
			throw new mergeException('No field Mapping found for the specified fieldType.');
			return;
		}
		
		if(fromId == null || fromId.trim() == '' || toId == null || toId.trim() == ''){		
			throw new mergeException('From and To cannot be blank or null.');
			return;
		}else if(!validateId(fromId)){
			throw new mergeException('From Id is not valid.');
			return;
		}else if(!validateId(toId)){
			throw new mergeException('To Id is not valid.');
			return;
		}
		
		for(MergeUtility_FieldConfig__c fieldMappingObj : mergeUtilityFieldMapping){
			if(objectFieldmap.containsKey(fieldMappingObj.Object_API_Name__c)){
				list<String> listLocStr = objectFieldmap.get(fieldMappingObj.Object_API_Name__c);
				listLocStr.add((String)fieldMappingObj.Field_API_Name__c);
				objectFieldmap.put(fieldMappingObj.Object_API_Name__c, listLocStr);
			}else{
				objectFieldmap.put(fieldMappingObj.Object_API_Name__c, new list<String>{fieldMappingObj.Field_API_Name__c});
			}
		}
		system.debug('objectFieldmap1 : '+objectFieldmap);
		
		for(String objectAPIName : objectFieldmap.keySet()){
			replaceLookup(objectAPIName, objectFieldmap.get(objectAPIName), fromId, toId);
		}
		
	}
	
	private void replaceLookup(String objectAPIName, list<String> listFieldAPIName, String fromId, String toId){
		
		String queryFields = '';
		String whereClause = '';
		
		for(String fieldAPIName : listFieldAPIName){
			if(whereClause == ''){
				whereClause = fieldAPIName + ' = \'' + fromId + '\'';
			}else{
				whereClause += ' OR ' + fieldAPIName + ' = \'' + fromId + '\'';
			}
		}
		
		String queryStr = 'select '+ String.join(listFieldAPIName, ', ') + ' from '+objectAPIName + ' where ' + whereClause;
		
		System.debug(queryStr);
		
		list<sObject> listSObject = Database.query(queryStr);
		
		for(sObject obj : listSObject){
			for(String fieldName : listFieldAPIName){
				if(obj.get(fieldName) <> null && obj.get(fieldName).equals(fromId)){
					obj.put(fieldName, toId);
				}
			}
		}
		
		System.debug('listSObject : '+listSObject);
		
		update listSObject;
	}
	
	private Boolean validateId(String Idparam){
		String id = String.escapeSingleQuotes(Idparam);
    	if((id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
    		return true;
    	}
    	return false;
	}
    
}
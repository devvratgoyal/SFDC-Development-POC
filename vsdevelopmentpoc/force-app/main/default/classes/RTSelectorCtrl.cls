/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-20-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-20-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class RTSelectorCtrl {
    @AuraEnabled
    public static List<RecordTypeWrapper> getContactRecordTypes() {
		List<RecordTypeWrapper> lstRecordTypes = new List<RecordTypeWrapper>();
        List<Schema.RecordTypeInfo> recordtypes = Contact.SObjectType.getDescribe().getRecordTypeInfos();
		for(RecordTypeInfo rt : recordtypes){
			if(rt.isAvailable()==True){
				if(rt.getName() != 'Master'){
					RecordTypeWrapper recordType = new RecordTypeWrapper();
                    recordType.value =rt.getName();
                    recordType.label = rt.getName();
                    recordType.isDefault =rt.isDefaultRecordTypeMapping();
                    lstRecordTypes.add(recordType);
                }
            }
		}
		return lstRecordTypes;
    }
	
	@AuraEnabled
	public static Id getRecTypeId(String recordTypeLabel){
		Id recid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
		return recid;
	}
}
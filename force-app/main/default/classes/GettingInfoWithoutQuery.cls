public with sharing class GettingInfoWithoutQuery {
    
    // Getting record type id without querying the object table.
    public void getRecordTypeId(){
        Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Contact;
        Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('EMC Internal Contact');
        Id rTypeId= record_Type_name_RT.getRecordTypeId();      
    }
    
    // Fetching list type custom Setting
    public List<String> getListCustomSetting(){
        List<String> stringList = new List<String>();
        List<List__c> customSettingListValues = List__c.getAll().values();
        for(List__c customSettingObj : customSettingListValues){
            stringList.add(customSettingObj.Name);
        }
        
        return stringList;
    }
    
    //Hierarchy__c CS = Hierarchy__c.getInstance();
    // Fetching Hierarchy type custom Setting
    public String getHierarchyCustomSetting(){
        Hierarchy__c customSettingVal = Hierarchy__c.getInstance();
                
        return customSettingVal.Name;
    }
}
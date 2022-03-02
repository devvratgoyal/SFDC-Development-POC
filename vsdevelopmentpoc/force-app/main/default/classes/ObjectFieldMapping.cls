public class ObjectFieldMapping{

    public List<SelectOption> listObjectName{get;set;}
    public String objectName{get;set;}
    public list<FieldMapWrapper> listFieldMapWrapper{get;set;}
    
    public map<String,map<String,String>> mapAllObjectsFields;
    public list<ObjectFieldWrapper> listObjectFieldWrapper{get;set;}
    
    public void getObjectFieldInfo(){
        listFieldMapWrapper = new list<FieldMapWrapper>();
        listObjectFieldWrapper = new list<ObjectFieldWrapper>();
        
        listObjectName = new List<SelectOption>();
        listObjectName.add(new SelectOption('-All-','All'));
        mapAllObjectsFields = new map<String,map<String,String>>();
        map<String,schema.SObjectType> mapSobjectType = schema.getGlobalDescribe();        
        String allObjectsFields = '';
        
        for(String sObj : mapSobjectType.keyset()){
            Schema.DescribeSObjectResult sObjectResult = mapSobjectType.get(sObj).getDescribe();
            String objectLabel = sObjectResult.getLabel();String objectName = sObjectResult.getName();
            listObjectName.add(new SelectOption(objectName, objectLabel));
            //system.debug('Object Label/Name :'+objectLabel+' / '+objectName);
            Map<String,Schema.SObjectField> SObjFields = sObjectResult.fields.getMap();
            map<String,String> mapObjectField = new map<String,String>();
            String fieldLabelName = '(';
            for(Schema.SObjectField sObjField : SObjFields.values()){
                //system.debug('Field Label/Name : '+sObjField.getDescribe().getLabel()+' / '+sObjField.getDescribe().getName());
                mapObjectField.put(sObjField.getDescribe().getLabel(),sObjField.getDescribe().getName());
                fieldLabelName += sObjField.getDescribe().getLabel()+':'+sObjField.getDescribe().getName()+',';
            }
            fieldLabelName = fieldLabelName.substring(0,fieldLabelName.length()-1);
            fieldLabelName += ')';
            allObjectsFields += '{'+objectLabel+':'+objectName+'}'+fieldLabelName;
            listObjectFieldWrapper.add(new ObjectFieldWrapper(objectLabel, objectName, mapObjectField));
            mapAllObjectsFields.put(objectName,mapObjectField);
        }
        listObjectName.sort();        
        system.debug('mapAllObjectsFields:'+mapAllObjectsFields);
    }
    
    public void fetchObject(){
        system.debug('Object Name : '+objectName);
        if(mapAllObjectsFields != null){
            for(String fieldlabel : mapAllObjectsFields.get(objectName).keyset()){
                listFieldMapWrapper.add(new FieldMapWrapper(objectName, fieldlabel, mapAllObjectsFields.get(objectName).get(fieldlabel)));
            }
            system.debug('Field Map : '+mapAllObjectsFields.get(objectName));
        }
    }
    
    public class ObjectFieldWrapper{
        public String objectLabel{get;set;}
        public String objectAPIName{get;set;}
        public map<String,String> fielddMap{get;set;}
        public ObjectFieldWrapper(String objLabel, String ObjAPINAme, map<String, String> mapFields){
            objectLabel = objLabel; objectAPIName = ObjAPINAme; fielddMap = mapFields;
        }
    }
    
    public class FieldMapWrapper{
        public String objectLabel{get;set;}
        public String fieldLabel{get;set;}
        public String fieldAPIName{get;set;}

        public FieldMapWrapper(String objLabel, String fieldLabel, String fieldAPINAme){
            objectLabel = objLabel; this.fieldAPINAme = fieldAPINAme; this.fieldLabel = fieldLabel;
        }
    }
}
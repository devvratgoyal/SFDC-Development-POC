/**
 * @File Name          : LeadsSelector.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 08-05-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/24/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class LeadsSelector extends fflib_SObjectSelector {
    public LeadsSelector() {
        super(false,false,false);
    }

    public LeadsSelector(Boolean enforceObjectAndFieldSecurity) {
        super(false, enforceObjectAndFieldSecurity, enforceObjectAndFieldSecurity);
    }

    public LeadsSelector(Boolean enforceObjectSecurity, Boolean enforceFieldSecurity) {
        super(false, enforceObjectSecurity, enforceFieldSecurity);
    }

    public LeadsSelector(Boolean includeFieldSetFields, Boolean enforceObjectSecurity, Boolean enforceFieldSecurity) {
        super(includeFieldSetFields, enforceObjectSecurity, enforceFieldSecurity);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Lead.Description,
            Lead.Id,
            Lead.Name
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Lead.sObjectType;
    }

    public override String getOrderBy() {
        return 'Name DESC, Id';
        
    }

    public List<Lead> selectById(Set<ID> idSet, Schema.FieldSet fieldSet) {
        return (List<Lead>) Database.query(
          newQueryFactory()
            .selectFieldSet(fieldSet)
            .setCondition('id in :idSet')
            .toSOQL()
        );
    }

    public List<Lead> selectById(Set<ID> idSet) {
        return (List<Lead>) Database.query(
          newQueryFactory()
            .setCondition('id in :idSet')
            .toSOQL()
        );
    }
      
}
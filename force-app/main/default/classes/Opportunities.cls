/**
 * @File Name          : Opportunities.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 6/7/2020, 1:40:27 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/26/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class Opportunities extends fflib_SObjectDomain{
    public Opportunities(List<Opportunity> sObjectList) {
        super(sObjectList);
        //Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Opportunities(sObjectList);
        }
    }

    public override void onApplyDefaults() {
        // Apply defaults to Opportunities
        for(Opportunity opportunity : (List<Opportunity>) Records) {
            opportunity.Description = 'Default Description';
        }
    }
    
    public override void onValidate() {
        // Validate Opportunities
        for(Opportunity oppy : (List<Opportunity>) Records) {
            if(oppy.Type != null && oppy.Type.startsWith('Existing') && oppy.AccountId == null) {
                oppy.AccountId.addError('You must provide an Account when ' +
                    'creating Opportunities for existing Customers.');
            }
        }
    }
    
    public override void onValidate(Map<Id,SObject> existingRecords) {
        // Validate changes to Opportunities
        for(Opportunity oppy : (List<Opportunity>) Records) {
            Opportunity existingOpp = (Opportunity) existingRecords.get(oppy.Id);
            if(oppy.Type != existingOpp.Type) {
                oppy.Type.addError('You cannot change the Opportunity type once it has been created');
            }
        }
    }

    public override void onBeforeInsert(){
        for(Opportunity oppy: (list<Opportunity>) Records){
            
        }
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords){
        for(Opportunity oppy: (list<Opportunity>) Records){
            Opportunity existingOppy =  (Opportunity) existingRecords.get(oppy.Id);
            if(oppy.Name != existingOppy.Name){
                oppy.Name.addError('You cannot change the Opportunity name once it has been created');
            }
        }
    }    
}
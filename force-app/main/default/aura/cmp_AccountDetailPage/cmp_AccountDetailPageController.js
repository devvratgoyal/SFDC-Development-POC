({
    init : function(component, event, helper) {
    },
    
    createContactRecord : function (component, event, helper) {
        var createAcountContactEvent = $A.get("e.force:createRecord");
        
        createAcountContactEvent.setParams({
            "entityApiName": "Contact",
            //"recordTypeId": RecTypeID,
            "defaultFieldValues": {	
                'AccountId' : component.get("v.recordId"),
                'Phone' : '123-456-1111',
            }
        });
        createAcountContactEvent.fire();
    }
})
({
    init : function(component, event, helper) {
    },

    openModal: function(component, event, helper) {
        var action = component.get("c.getContactRecordTypes");
        action.setCallback(this, function(response) {
            //default record type selection
            var listRT = response.getReturnValue();
            for(var i=0; i< listRT.length; i++){
                if(listRT[i].isDefault){
                    component.set("v.defaultContactRT",listRT[i].value);
                }
            }
            component.set("v.options", listRT);
            // set "isOpen" attribute to true to show model box
            component.set("v.isOpen", true);
        });
        $A.enqueueAction(action);
     },

     closeModal: function(component, event, helper) {
        // set "isOpen" attribute to false for hide/close model box 
        component.set("v.isOpen", false);
     },

     createContactRecord : function (component, event, helper) {
        
        //alert(component.get("v.recordId"));
        var action = component.get("c.getRecTypeId");
        //var recordTypeLabel = component.find("selectid").get("v.value");
        var recordTypeLabel = component.find("RTLabel").get("v.value");
        action.setParams({
          "recordTypeLabel": recordTypeLabel
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var createRecordEvent = $A.get("e.force:createRecord");
                var RecTypeID  = response.getReturnValue();
                createRecordEvent.setParams({
                    "entityApiName": "Contact",
                    "recordTypeId": RecTypeID,
                    "defaultFieldValues": {	
                        'AccountId' : component.get("v.recordId")
                    }
                });
                createRecordEvent.fire();
            }  
        });
        $A.enqueueAction(action);
    }
})
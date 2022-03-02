({
    init : function(component, event, helper) {
        var action = component.get("c.getAccountId");
        action.setParams({
            "contactId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.accountId",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    editAccountRecord : function (component, event, helper) {
        
        //alert('Editing account for accountId: '+component.get("v.accountId")+' using standard event : force:editRecord');
        
        var editAccountEvent = $A.get("e.force:editRecord");
        editAccountEvent.setParams({
            "recordId": component.get("v.accountId")
        });
        editAccountEvent.fire();
    },

    navigateToAccountRecord : function (component, event, helper) {
        
        //alert('Navigating back to Account for account Id: '+component.get("v.accountId")+' using standard event : force:editRecord');
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.accountId"),
            "slideDevName": "related"
        });
        navEvt.fire();
    },

    navigateToAccountHome : function (component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Account"
        });
        homeEvent.fire();
    },

    navigateToMyComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:cmp_AccountDetailPage",
            componentAttributes: {
                recordId : component.get("v.accountId")
            }
        });
        evt.fire();
    }
    
    
})
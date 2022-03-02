({
    init : function(component, event, helper) {
		var action = component.get("c.getAccountIdForOpportunity");
        action.setParams({opportunityId:component.get('v.recordId')});
        action.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            if(resp!=null && resp!=''){
            	component.set('v.accountId',resp);
            }
        });
        $A.enqueueAction(action);
	}
})
({
	myAction : function(component, event, helper) {
		// fetch lighting component attribute from lightning component
		var accRecordId = component.get("v.recordId");
        //Create apex controller method instance
		var action = component.get("c.getContacts");		
		//Setting static and dynamic parameters from component to Apex controller 
		action.setParams({  ctrlAccountId : accRecordId,activeflag : true,myStringParam : 'TestStr'  });		
		//Call apex controller method instance
		$A.enqueueAction(action);
		//After apex controller method call, initialize lightning component attributes from return of the apex method
		action.setCallback(this, function(data) {
            var state = data.getState();
            if(state == "SUCCESS"){
                if(data.getReturnValue().length > 0){
                    component.set("v.Contacts", data.getReturnValue());
                    component.set("v.AccountName", data.getReturnValue()[0].Account.Name);                            	
                }else{
                    alert('No contacts for this account.'); 
                }
            }else if(state == "ERROR"){
                alert('Error in calling server side action'); 
            }		    
		});
				
	},
    goToAccountSelection : function(component, event, helper) {
		console.log('Enter Here');
        var evt = $A.get("e.force:navigateToComponent");
        console.log('evt'+evt);
        evt.setParams({
            componentDef: "c:LightiningComponentStartPage",
            componentAttributes :{ recordId :component.get("v.recordId")}                
        });
       
		evt.fire();
	},
})
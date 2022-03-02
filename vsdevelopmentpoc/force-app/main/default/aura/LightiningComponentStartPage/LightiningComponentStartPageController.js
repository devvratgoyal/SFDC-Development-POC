({
	myAction : function(component, event, helper) {
        var recordid = component.get("v.recordId");
        if(recordid != null){
            component.find("accountId").set("v.value",recordid);
            var a = component.get('c.displayContacts');
            $A.enqueueAction(a);			            
        }
		var action = component.get("c.getAccounts");		
		$A.enqueueAction(action);
		//After apex controller method call, initialize lightning component attributes from return of the apex method
		action.setCallback(this, function(data) {
            var state = data.getState();
            if(state == "SUCCESS"){
            	component.set("v.AccountList", data.getReturnValue());            	
            }else if(state == "ERROR"){
                alert('Error in calling server side action'); 
            }		    
		});				
	},
	onSingleSelectChange : function(component) {
		component.set("v.Contacts", null);        
	},
	displayContacts : function(component, event, helper) {
		// fetch lighting component attribute from lightning component
		
        var accountIdStr = component.find("accountId").get("v.value");
        if(accountIdStr != ''){
            if(component.get('v.columns') == ''){
                var actions = helper.getRowActions.bind(this, component);
                component.set('v.columns', [
                    {label: 'First Name', fieldName: 'FirstName', type: 'text', editable : 'true', sortable: 'true'},
                    {label: 'Last Name', fieldName: 'LastName', type: 'text', editable : 'true', sortable: 'true'},
                    {label: 'Contact Email', fieldName: 'Email', type: 'email', editable : 'true', sortable: 'true'},
                    {label: 'Contact Phone', fieldName:'Phone', type: 'phone', editable : 'true', sortable: 'true'},
                    { type: 'action', typeAttributes: { rowActions: actions } }
                ]);
            }  
            //helper.addContactColumns(component, event);
			//Create apex controller method instance
			var action = component.get("c.getContacts");
            var limits = 10;
            var offset = 5;
			//Setting static and dynamic parameters from component to Apex controller 
			action.setParams({  ctrlAccountId : accountIdStr,intlimits : limits,intoffsets : offset  });		
			//Call apex controller method instance
			$A.enqueueAction(action);
			//After apex controller method call, initialize lightning component attributes from return of the apex method
			action.setCallback(this, function(data) {
	            var state = data.getState();
	            if(state == "SUCCESS"){
	                if(data.getReturnValue().length > 0){
	                    component.set("v.Contacts", data.getReturnValue());
                        //alert(data.getReturnValue()[0].Account.Name);
                        component.set("v.AccountName", data.getReturnValue()[0].Account.Name);						                        
	                }
	            }else if(state == "ERROR"){
	                alert('Error in calling server side action'); 
	            }		    
			});
            var totalCnt = component.get("c.getTotalCount");
            action.setParams({  ctrlAccountId : accountIdStr});
            totalCnt.setCallback(this, function(data) {
                component.set("v.totalNumberOfRows", data.getReturnValue());
            });
            $A.enqueueAction(totalCnt);
            //component.find("accordion").set('v.activeSectionName', 'ContactSection');
            component.find("accordion").set('v.activeSectionName', ['ContactDTSection']);
		}
	},
    loadMoreData: function (component, event, helper) {
        var rowsToLoad = component.get('v.rowsToLoad'),
            fetchData = component.get('v.dataTableSchema'),
            promiseData;

        event.getSource().set("v.isLoading", true);
        component.set('v.loadMoreStatus', 'Loading');
        
		var accountIdStr = component.find("accountId").get("v.value");
        if(accountIdStr != ''){
          	var action = component.get("c.getContacts");		
			action.setParams({  ctrlAccountId : accountIdStr,intlimits : 10,intoffsets : 5  });		
			$A.enqueueAction(action);
			action.setCallback(this, function(data) {
	            var state = data.getState();
	            if(state == "SUCCESS"){
	                if(data.getReturnValue().length > 0){
	                    if (component.get('v.Contacts').length >= component.get('v.totalNumberOfRows')) {
                            component.set('v.enableInfiniteLoading', false);
                            component.set('v.loadMoreStatus', 'No more data to load');
                        } else {
                            var currentData = component.get('v.Contacts');
                            var newData = currentData.concat(data.getReturnValue());
                            component.set('v.Contacts', newData);
                            component.set('v.loadMoreStatus', '');
                            event.getSource().set("v.isLoading", false);
                        	component.set("v.AccountName", data.getReturnValue()[0].Account.Name);	
                        }
	                }
	            }else if(state == "ERROR"){
	                alert('Error in calling server side action'); 
	            }		    
			});
		}        
    },
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'show_details':
                alert('Showing Details: ' + JSON.stringify(row));
                break;
            case 'edit':
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": row.Id,
                    "navigationLocation":"LOOKUP"
               	});
                editRecordEvent.fire();
                break;
            case 'delete':
                helper.removeDataTableRow(component, row);
                break;
        }
    },
    deleteContacts: function(component, event, helper) {
        var action = component.get("c.deleteContactsCtr");
        action.setParams({
            listContactDel: component.find('contactTable').getSelectedRows(),
            accountIdStr : component.find("accountId").get("v.value")
        });    
        $A.enqueueAction(action);
        action.setCallback(this, function(data) {
	            if(data.getState() == "SUCCESS"){
                    if(data.getReturnValue() != null && data.getReturnValue().length > 0){
	                    component.set("v.Contacts", data.getReturnValue());
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            type : "success",
                            "message": "The record/(s) deleted successfully."
                        });
                        toastEvent.fire();
                	}
                }
        });
        
    },
    handleContactSave: function(component, event, helper) {
        //alert(component.find('contactTable').getSelectedRows());
        //alert(component.find('contactTable').getSelectedRows().length);
        //alert(component.get('v.Contacts').length);
        var draftValues = event.getParam('draftValues');
        var action = component.get("c.updateContacts");
        action.setParams({
            "listContact" : draftValues,//component.get("v.Contacts"),
            "accountIdStr" : component.find("accountId").get("v.value")
        });
        $A.enqueueAction(action);
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                if(data.getReturnValue() != null && data.getReturnValue().length > 0){
                    component.set("v.Contacts", data.getReturnValue());
                    component.set("v.draftValues", null);
                    event.setParam('draftValues',null);
                }
            }
        });
    },
    createRecord: function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Contact", // using account standard object for this sample
            "defaultFieldValues": {
                'Phone' : '415-240-6590',
                'AccountId' : component.find("accountId").get("v.value")
            },
            "panelOnDestroyCallback": function(event) {
                var a = component.get('c.displayContacts');
                $A.enqueueAction(a);    
            },
            "navigationLocation":"LOOKUP" // to close popup after button click 
        });
        createRecordEvent.fire();
        //component.find("accountId").set("v.value",recordid);
        
   	},
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    // function for save the contact Records 
    Save: function(component, event, helper) {
        // first call the helper function in if block which will return true or false.
        // this helper function check the "first Name" will not be blank on each row.
        if (helper.validateRequired(component, event)) {
            // call the apex class method for save the Contact List
            // with pass the contact List attribute to method param.  
            var action = component.get("c.saveContacts");
            action.setParams({
                "ListContact": component.get("v.Contacts"),
                "accountId": component.find("accountId").get("v.value")
            });
            // set call back 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    alert('record Save');
                }
            });
            // enqueue the server side action  
            $A.enqueueAction(action);
        }
    },
    //function to display contact on new component
 	goToContactsPage : function(component, event, helper) {
		console.log('Enter Here');
        var accountIdStr = component.find("accountId").get("v.value");
        var evt = $A.get("e.force:navigateToComponent");
        console.log('evt'+evt);
        evt.setParams({
            componentDef: "c:ContactsforAccount",
            componentAttributes :{ recordId :accountIdStr}                
        });
       
		evt.fire();
	},
    goToContactsPageEvent : function(component, event, helper) {
		var accountIdStr = component.find("accountId").get("v.value");
        var updateEvent = component.getEvent("showContactPageEvent");
        updateEvent.setParams({ "accountId": accountIdStr });
        updateEvent.fire();
	},
    AddRow : function(component, event, helper){
        helper.createObjectData(component, event);     
    },
    // function for delete the row 
    RemoveRow: function(component, event, helper) {
        helper.removeRowData(component, event);        
    },
    handleSetActiveSectionAccount: function (cmp) {
        cmp.find("accordion").set('v.activeSectionName', 'AccountSection');
    },
    handleSetActiveSectionContact: function (cmp) {
        cmp.find("accordion").set('v.activeSectionName', 'ContactSection');
    },
    handleMenuItem: function (component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        if(selectedMenuItemValue == 'RefreshList'){
            var a = component.get('c.displayContacts');
            $A.enqueueAction(a);
        }else{
        	alert("Menu item selected with value: " + selectedMenuItemValue);    
        }        
    }
})
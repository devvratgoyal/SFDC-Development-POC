({
    createObjectData: function(component, event) {
        // get the Contacts from component and add(push) New Object to List  
        var RowItemList = component.get("v.Contacts");
        if(RowItemList == null){
            RowItemList = {
                'sobjectType': 'Contact',
                'FirstName': '',
                'LastName': '',
                'Email': '',
                'Phone': '',
                'Id' : ''
            };
        }else{
            RowItemList.push({
                'sobjectType': 'Contact',
                'FirstName': '',
                'LastName': '',
                'Email': '',
                'Phone': '',
                'Id' : ''
            });
        }        
        // set the updated list to attribute (Contacts) again    
        component.set("v.Contacts", RowItemList);
        //event.setParams({"draftValues" : RowItemList });
    },
    removeRowData: function(component, event) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        // get the all List (contactList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.Contacts");
        AllRowsList.splice(index, 1);
        // set the Contacts after remove selected row element  
        component.set("v.Contacts", AllRowsList);
    },
    // helper function for check if first Name is not null/blank on save  
    validateRequired: function(component, event) {
        var isValid = true;
        var allContactRows = component.get("v.Contacts");
        for (var indexVar = 0; indexVar < allContactRows.length; indexVar++) {
            if (allContactRows[indexVar].FirstName == '') {
                isValid = false;
                alert('First Name Can\'t be Blank on Row Number ' + (indexVar + 1));
            }
        }
        return isValid;
    },
    getRowActions: function (component, row, doneCallback) {
        var actions;
        var rows = component.get('v.Contacts');
        var rowIndex = rows.indexOf(row);
        if(rowIndex == -1){
            actions = [
                { label: 'Delete', name: 'delete' }
            ];
        }else{
            actions = [
                { label: 'Detail', name: 'show_details'},
                { label: 'Edit', name: 'edit' }
            ];
        }
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },
    addContactColumns: function(component, event, actions){
        component.set('v.columns', [
            {label: 'First Name', fieldName: 'FirstName', type: 'text', editable : 'true', sortable: 'true'},
            {label: 'Last Name', fieldName: 'LastName', type: 'text', editable : 'true', sortable: 'true'},
            {label: 'Contact Email', fieldName: 'Email', type: 'email', editable : 'true', sortable: 'true'},
            {label: 'Contact Phone', fieldName:'Phone', type: 'phone', editable : 'true', sortable: 'true'},
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);
    },
    removeDataTableRow: function (component, row) {
        var rows = component.get('v.Contacts');
        var rowIndex = rows.indexOf(row);
        rows.splice(rowIndex, 1);
        component.set('v.Contacts', rows);
    },
	sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.Contacts");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.Contacts", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }    
})
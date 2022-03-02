({
	COLUMNS: [
        { label: 'Owner', fieldName: 'owner', type: 'text', sortable: 'true'},
        { label: 'Total Leads', fieldName: 'totalLeads', type: 'number', sortable: 'true'},
        { label: 'Total Opps.', fieldName: 'totalOpportunities', type: 'number', sortable: 'true'},
        { label: 'Conv Rate', fieldName: 'conversionRate', type: 'percent', sortable: 'true', typeAttributes:{
            minimumFractionDigits: "2"}},
        { label: 'Max Created Date (Opp)', fieldName: 'maxCreatedDate', type: 'date-local', sortable: 'true',typeAttributes:{
            month: "2-digit", day: "2-digit"
        }, cellAttributes: { alignment: 'right' }},
        { label: 'Total Val (Opp)', fieldName: 'totalOppyValue', type: 'currency', sortable: 'true', 
            typeAttributes: { currencyCode: 'USD'}}
    ],
    
    setColumns: function(cmp) {
        cmp.set('v.columns', this.COLUMNS);
    },

    getData: function(cmp,startDate,enddate) {
        if(startDate == null && enddate == null){
            var enddate = new Date();
            var formatedEndDate= enddate.toISOString();
            cmp.set("v.opportunityCloseDate",formatedEndDate );
            startDate = new Date();
            startDate.setDate(startDate.getDate() - 30);
            var formatedStartDate= startDate.toISOString();
            cmp.set("v.leadStartDate",formatedStartDate );
        }

        
        var action = cmp.get("c.getLeadOpportunity");
        action.setParams({  leadCreateDate : startDate,oppyClosedDate : enddate});
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                cmp.set('v.data', response.getReturnValue());                
            }else if(state == "ERROR"){
                alert('Error in calling server side action'); 
            }		    
        }));
        $A.enqueueAction(action);        
    },

    setData: function(cmp) {
        cmp.set('v.data', this.DATACMP);
    },

    // Used to sort the 'Age' column
    sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },

    handleSort: function(cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');

        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
        this.sortData(cmp,sortedBy,sortDirection);
    },

    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.data");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
         if(fieldName == 'totalOpportunities' || fieldName == 'totalLeads' || fieldName == 'conversionRate' || fieldName == 'totalOppyValue'){  
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else{// to handel text type fields 
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }
        
        component.set("v.data",data);
    }

})
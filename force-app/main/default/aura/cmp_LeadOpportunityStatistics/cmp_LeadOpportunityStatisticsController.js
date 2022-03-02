({
	myAction : function(cmp, event, helper) {
		helper.setColumns(cmp);
        helper.getData(cmp,null,null);
    },
    
    handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    },
    
    validateSubmit: function(cmp, event, helper) {
        var startDate = new Date(cmp.get("v.leadStartDate")); 
        var endDate = new Date(cmp.get("v.opportunityCloseDate"));        
        if(startDate == 'Invalid Date'){
            cmp.set("v.dateValidationError" , true);
            cmp.set("v.dateValidationErrorMsg" , "Please insert valid start date.");
        }else if(endDate == 'Invalid Date'){
            cmp.set("v.dateValidationError" , true);
            cmp.set("v.dateValidationErrorMsg" , "Please insert valid end date.");        
        }else if(startDate>endDate){
            cmp.set("v.dateValidationError" , true);
            cmp.set("v.dateValidationErrorMsg" , "Start date cannot be greater than end date.");
        }else{
            var days = (endDate-startDate)/8.64e7;
            if(days >31){
                cmp.set("v.dateValidationError" , true);
                cmp.set("v.dateValidationErrorMsg" , "End date cannot be greater than 31 days from start date.");
            }else{
                cmp.set("v.dateValidationError" , false);
                cmp.set("v.dateValidationErrorMsg" , "");                
                helper.getData(cmp,startDate,endDate);
            }
        }
    }
})
({
    AddNewRow : function(component, event, helper){
       // fire the AddRowCmpEvt Lightning Event from child component
        component.getEvent("AddRowCmpEvt").fire();     
    },
    
    removeRow : function(component, event, helper){
        // fire the DeleteRowCmpEvt Lightning Event from child component and pass the deleted Row Index to Event parameter/attribute
        var cmpEvent = component.getEvent("DeleteRowCmpEvt")
        cmpEvent.setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    }  
})
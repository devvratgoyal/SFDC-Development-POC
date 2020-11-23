({
    readFile: function(component, helper, file, userId) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
            return alert('Image file not supported');
        }
        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            console.log(dataURL);
            component.set("v.pictureSrc", dataURL);
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1], userId);
        };
        reader.readAsDataURL(file);
    },
     
    upload: function(component, file, base64Data, userId) {
        var action = component.get("c.saveAttachment"); 
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: base64Data, 
            contentType: file.type,
            currentUserID: userId
        });
        action.setCallback(this, function(a) {
            component.set("v.message", "Image uploaded");
        });

        component.set("v.message", "Uploading...");
        $A.enqueueAction(action); 
    },

    validateUser: function(component, helper, files, userId) {
        
        var action = component.get("c.isUploadableByUser"); 
        action.setParams({
            parentId: component.get("v.recordId"),
            currentLoggedUser: userId
        });
        action.setCallback(this, function(response) {

            if (response.getState() === "SUCCESS") {
                console.log(response.getState());
                helper.readFile(component, helper, files[0],userId);
           }
           else if (response.getState() === "ERROR") {
                component.set("v.messageType", 'error' ); 
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error message: " +errors[0].message);
                        component.set("v.message",errors[0].message);
                        alert(errors[0].message);
                        location.reload();
                    }
                }
                
           }
        });

        $A.enqueueAction(action); 
    }
 
})
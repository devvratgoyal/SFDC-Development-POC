/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-20-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-20-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class UploadProfilePictureCtrl {
     
    @AuraEnabled
    public static Attachment getProfilePicture(Id parentId) {
 
        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Contact.isAccessible()) {
            if(true){
                throw new System.NoAccessException();
            }
            return null;
        }
  
        return [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
            WHERE parentid=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') AND Description LIKE 'DP for:%'
            ORDER BY LastModifiedDate DESC LIMIT 1];
    }
     
    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data, String contentType, Id currentUserID) { 
 
        // Edit permission on parent object (Contact) is required to add attachments
        if (!Schema.sObjectType.Contact.isUpdateable()) {
            if(true){
                throw new System.NoAccessException();
            }
            return null;
        }
        
        Contact con = [SELECT Id,Name,FirstName, LastName FROM Contact
                        WHERE Id =: parentId];
        
        Attachment attachment = new Attachment();
        attachment.parentId = parentId;
        attachment.body = EncodingUtil.base64Decode(base64Data);
        attachment.name = fileName;
        attachment.contentType = contentType;
        attachment.Description = 'DP for:'+con.Firstname+'_'+con.Lastname+'_'+date.today().format();
        insert attachment;
        return attachment.id;
    }

    @AuraEnabled
    public static boolean isUploadableByUser(Id parentId, Id currentLoggedUser){

        boolean isUploadable = false;
        if(UserInfo.getUserId() == currentLoggedUser){
            isUploadable = true;
        }
        
        if(!isUploadable){
            if(true){
                throw new AuraHandledException('You can only update your own Profile Picture');
            }
            return false;
        }else{
            return true;
        }
        
    }
    
    //@AuraEnabled
    public static List<Database.DeleteResult> deleteContactPicture(Id parentId){
        
        List<Attachment> attList = [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
            WHERE parentid=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') AND Description LIKE 'DP for:%'
            ORDER BY LastModifiedDate DESC LIMIT 1];
        
        return Database.delete(attList, false);

    }
 
}
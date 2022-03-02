public class EmailTest {
	
	public Pagereference GetIntegrationReconciliationData(){
		
		Blob body = Blob.valueOf('Trial,Data\nDev,Goyal');
        
        Messaging.Emailfileattachment attach = new Messaging.Emailfileattachment();
        attach.setFileName('Test.csv');
        //attach.setContentType('application/vnd.ms-excel');
        attach.setContentType('text/csv');
        attach.setBody(body);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    mail.setUseSignature(false);
	    mail.setToAddresses(new String[] { 'tellgoyaldev@gmail.com' });
	    mail.setSubject('PDF Demo');
	    mail.setPlainTextBody('Trail Text Email Body');
	    
	    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
	    // Send the email
	    
	    List<Messaging.Sendemailresult> ss= Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	    System.debug('ss @@@@@@ :  '+ss);
 
        //application/vnd.ms-excel
		
		return null;
	}

}
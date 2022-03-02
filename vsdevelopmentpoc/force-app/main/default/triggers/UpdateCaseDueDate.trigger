trigger UpdateCaseDueDate on Case (before insert) {
	
	/*for(Case c : trigger.new){
		c.Due_Date__c = c.CreatedDate + 2;
	}*/
}
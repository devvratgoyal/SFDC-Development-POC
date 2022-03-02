trigger ContactUndelete on Contact (after undelete) {
	
	for(Contact conObj : trigger.New){
		System.debug('conObj.Firstname : '+conObj.Firstname);
	}

}
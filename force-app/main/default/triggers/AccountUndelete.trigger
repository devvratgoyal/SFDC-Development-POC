trigger AccountUndelete on Account (after undelete) {
	
	for(Account accobj : trigger.New){
		System.debug('accobj.Name : '+accobj.Name);
	}
}
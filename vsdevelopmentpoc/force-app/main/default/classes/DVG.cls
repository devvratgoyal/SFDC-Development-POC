GLOBAL class DVG {
	
	public DVG(){
		list<Account> accList = new List<Account> ([select accountnumber from Account where name = 'acme']);
		system.debug(accList[0].Name);
	}
	
	@future
	public static void doMyStuff(Id obj){
	
	}
	
	@future
	public static void callDoMyStuff(Id obj){
		DVG.doMyStuff(null);
		APEXPAGES.STANDARDSETCONTROLLER TESTCTRL = NEW APEXPAGES.STANDARDSETCONTROLLER(NEW ACCOUNT[]{});
		APEXPAGES.STANDARDSETCONTROLLER TESTCTRL1 = NEW APEXPAGES.STANDARDSETCONTROLLER(DATABASE.GETqUERYlOCATOR([SELECT ID FROM ACCOUNT]));
		APEXPAGES.STANDARDSETCONTROLLER TESTCTRL2 = NEW APEXPAGES.STANDARDSETCONTROLLER(DATABASE.QUERY('SELECT ID FROM ACCOUNT'));
	}
	
	webservice static boolean checkCreate(){
		Schema.DescribeSobjectResult s = Account.SobjectType.getDescribe();
		return s.isCreateable();
	} 
}
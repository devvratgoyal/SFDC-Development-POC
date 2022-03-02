public class WeekController {
	
	public boolean statusMessage {get{
		Account acc = [select id,LastModifiedDate from Account limit 1];
		update acc;
		schema.DescribeSobjectResult s = Account.sobjectType.getDescribe();
		return s.isCreateable();
	} private set;}
	
	public Week daysOfTheWeek{
		get{
			if(daysOfTheWeek == null) daysOfTheWeek = new Week();
			return daysOfTheWeek;
		}		
		set;
	}
	
	public String out{
		get {
			if(out == null) out = 'getter';
			return out;
		}
		set;
	}
	
	public WeekController(){
		
		out = 'constructor : ' + SYSTEM.TODAY() + 7;
	}
	
	public void setOut(){
		out = 'action';
	}
	
	public pageReference getPageRef(){
		pagereference p = Page.WeekPage;
		p.getParameters().put('key','value');
		return p;
	}
	
	public string input{
		get{
			if(input == null) input = 'default';
			return input;
		}set;
	}
	
	public void go(){}
	
	public void doMyStuff(){
		//MyException myEx = new MyException('What are you doing buddy.');
		Apexpages.message myMsg = new Apexpages.message(Apexpages.Severity.Error, 'my Message is being displayed.');
		Apexpages.addMessage(myMsg);
	}
	
	public class MyException extends Exception{
		
	}
}
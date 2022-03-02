public class TestController{
    
    public List<MyFriends__c> myAllFriends{get;set;}
    
    private MyFriends__c obj;
    
    public TestController(){
    	obj = new MyFriends__c();
    }
    
    public Pagereference TestController(Apexpages.standardController stdCtrl){
    	obj = (MyFriends__c) stdCtrl.getRecord();
    	Apexpages.standardsetcontroller setCtrl = new Apexpages.standardsetcontroller(Database.GetQueryLocator('Select Id from account')); 
    	return null;    	
    }
    
    private String likeStr = '%12%';
    
    public Pagereference testMethod2(){
        
        myAllFriends = new List<MyFriends__c>();
        
        myAllFriends = [select Fname__c, Lname__c from MyFriends__c where Lname__c like : likeStr limit 500];
        
        if(myAllFriends == null || myAllFriends.isEmpty()){
            myAllFriends =   testMethod1();  
        }
        
        return null;        
    }
    
    public List<MyFriends__c> testMethod1(){
        
        List<MyFriends__c> listMyFriend = new List<MyFriends__c>();
        MyFriends__c objMyFriend;
        for(Integer i=1;i<=125;i++){
            objMyFriend = new MyFriends__c(Fname__c = 'Vijay', Lname__C = 'Patel'+i);
            listMyFriend.add(objMyFriend);
        }
        
        try{
            insert listMyFriend;
        }catch(DMLException ex){
            System.debug('Exception : '+ex.getMessage());
        }
        
        listMyFriend = [select Fname__c, Lname__c from MyFriends__c where Lname__c like : likeStr limit 500]; 
        
        return listMyFriend;
        
    }
}
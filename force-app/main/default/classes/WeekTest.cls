@isTest
public class WeekTest {

    public static testMethod void myUnitTest() {
        system.assertEquals(6,5+2);
        Account[] acclist = [select a.id, a.Name from Account a where a.Name = 'test'];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new Account[]{});
        
    }
}
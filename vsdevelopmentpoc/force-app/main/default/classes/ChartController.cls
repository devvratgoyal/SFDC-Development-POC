public class ChartController{
    
    // Get a set of Opportunities
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [SELECT name, type, amount, closedate FROM Opportunity]));
                setCon.setPageSize(5);
            }
            return setCon;
        }
        set;
    }
    
    public List<Opportunity> getOpportunities() {
         return (List<Opportunity>) setCon.getRecords();
    }
}
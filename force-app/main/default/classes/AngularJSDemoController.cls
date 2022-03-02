global class AngularJSDemoController{ 
    
    public String AccountList { get; set; }
    
    //Subclass : Wrapper Class 
    public class Accountwrap {
        //Static Variables 
        public string id;
        public string name;
        public string Phone;
        public string Fax;
        public string Website;
        
        //Wrapper  Class Controller
        Accountwrap() {
            Phone = '';
            Fax = '';
            Website = '';
        }
        
    }
       
    //Method to bring the list of Account and Serialize Wrapper Object as JSON
    public  static String getlstAccount() {
        List < Accountwrap > lstwrap = new List < Accountwrap > ();
        List < account > lstacc = [SELECT Id, Name, Phone,Fax,Website
                                   FROM Account order by name limit 10
                                  ];
        for (Account a: lstacc) {
            Accountwrap awrap = new Accountwrap();
            awrap.id = a.id;
            awrap.name = a.name;
            if (a.Phone != null) {
                awrap.Phone = a.Phone;
            }
            if (a.Fax != null) {
                awrap.Fax = a.Fax;
            }
            if (a.Website != null) {
                awrap.Website = a.Website;
            }
            lstwrap.add(awrap);
        }
        return JSON.serialize(lstwrap);
     }
    @RemoteAction
    global static string createAccount(string name,string phone,string fax,string website){
        String fax1 = fax == 'null' ? NULL : fax;
        String website1 = website == 'null' ? NULL : website;
        Account acc = new Account(name=name,phone=phone,fax=fax1,website=website1);
        insert acc;
        return acc.id;
    }
    @RemoteAction
    global static void updateAccount(string id,string name,string phone,string fax,string website){
        String fax1 = fax == 'null' ? NULL : fax;
        String website1 = website == 'null' ? NULL : website;
        Account acc = new Account(name=name,phone=phone,id=id,fax=fax1,website=website1);
        update acc;
    }
    @RemoteAction
    global static void deleteAccount(string id){
        Account acc = [select id from account where id =: id];
        delete acc;
    }
}
public with sharing class SelectionExample {
	
	public String msLeftSelected{get;set;}
	public String msRightSelected{get;set;}
	
	public selectOption[] leftSelected{get;set;}	
    public selectOption[] rightselected{get;set;}
    
	public SelectionExample(){
		leftselected = new selectOption[]{};
		for(integer i=1; i<6;i++){
			leftselected.add(new Selectoption('ElementKey'+i,'Element '+i));
		}
    	rightselected = new selectOption[]{};
	}
	
	public PageReference selectClick(){
    	msRightSelected = '';
        Integer i = 0;
        While(i<leftSelected.size()) {               
             if(leftSelected[i].getvalue()==msLeftSelected) {                  
                 rightSelected.add(new SelectOption(leftSelected[i].getvalue(),leftSelected[i].getlabel()));
                 leftSelected.remove(i);                 
              }
              i++;
        }
        return null;
    }
    
    public PageReference unselectClick(){
    	msLeftSelected = '';          
        Integer i = 0;
        While(i<rightSelected.size()) { 
            if(rightSelected[i].getvalue()==msRightSelected) {   
                leftSelected.add(new SelectOption(rightSelected[i].getvalue(), rightSelected[i].getlabel()));
                rightSelected.remove(i);                
            }
            i++;
        }  
        return null;
    }
}
global class Week {
	
	public list<Day> days {get;set;}
	
	public Week(){
	
		days = new list<Day>();
		for(integer i =0; i<7; i++){
			Day d = new Day(i);
			days.add(d);
		}
	}
	
	webservice static SOBJECT sayello(sOBJECT str){
		MAP<sTRING,SCHEMA.SOBJECTTYPE> ACCLiST = SCHEMA.GETGLOBALDESCRIBE();
		return NULL;
	}
	
	public class Day{
		public String dayLabel {get; private set;}
		public Boolean checked {get; set;}
		
		public Day(Integer dayValue){
			if (dayValue == 0){
				this.dayLabel = 'Sunday';
			}else if (dayValue == 1){
				this.dayLabel = 'Monday';
			}else if (dayValue == 2){
				this.dayLabel = 'Tuesday';
			}else if (dayValue == 3){
				this.dayLabel = 'Wednesday';
			}else if (dayValue == 4){
				this.dayLabel = 'Thursday';
			}else if (dayValue == 5){
				this.dayLabel = 'Friday';
			}else if (dayValue == 6){
				this.dayLabel = 'Saturday';
			}
			
			this.checked = false;
		}
	}

}
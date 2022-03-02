import { LightningElement, track } from 'lwc';

export default class ConditionalRenderingExample extends LightningElement {
    @track displaydiv=false;

    @track cityList = ['Jaipur', 'Udaipur', 'Hyderabad'];

    toggleDiv(event){
        this.displaydiv = event.target.checked;
        if(this.displaydiv){
            this.cityList = ['NYC', 'SFO', 'Chicago'];
        }else{
            this.cityList = ['Jaipur', 'Udaipur', 'Hyderabad'];
        }
    }
}
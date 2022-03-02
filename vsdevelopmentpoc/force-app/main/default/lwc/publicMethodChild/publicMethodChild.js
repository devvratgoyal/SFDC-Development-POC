import { LightningElement, track, api } from 'lwc';

export default class PublicMethodChild extends LightningElement {
    checkBoxValue = ['Red'];

    options = [
        { label: 'Red Marker', value: 'Red' },
        { label: 'Blue Marker', value: 'Blue' },
        { label: 'Green Marker', value: 'Green' },
        { label: 'Yellow Marker', value: 'Yellow' }
    ];

    @api
    selectCheckbox(textValue){
        const selectedCheckbox = this.options.find( option =>{
            return textValue === option.value;
        })
        if(selectedCheckbox){
            this.checkBoxValue =  selectedCheckbox.value;
        }
    }    

}
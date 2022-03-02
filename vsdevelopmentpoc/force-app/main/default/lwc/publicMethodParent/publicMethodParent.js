import { LightningElement, track, api } from 'lwc';

export default class PublicMethodParent extends LightningElement {
    @track textInput;

    inputChangeHandler(event){
        this.textInput = event.target.value;
        const childComponet = this.template.querySelector('c-public-method-child');
        childComponet.selectCheckbox(this.textInput);
    }
}
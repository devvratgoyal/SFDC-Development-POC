import { LightningElement } from 'lwc';
export default class HelloWorld extends LightningElement {
  greeting = 'Friend';
  changeHandler(event) {
    this.greeting = event.target.value;
  }
}
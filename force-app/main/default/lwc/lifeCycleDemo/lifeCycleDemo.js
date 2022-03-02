import { LightningElement } from 'lwc';

export default class LifeCycleDemo extends LightningElement {

    constructor(){
        super();
        console.log('Constructor for lifeCycleDemo is called');
    }
    
    connectedCallback(){
        console.log('ConnectedCallback for lifeCycleDemo is called');
    }

    renderedCallback(){
        console.log('RenderedCallback for lifeCycleDemo is called');
    }

    disconnectedCallback(){
        console.log('DisconnectedCallback for lifeCycleDemo is called');
    }
}
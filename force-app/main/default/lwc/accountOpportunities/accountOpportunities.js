import { LightningElement, wire, api } from 'lwc';

import getOpportunitiesByAccountId from '@salesforce/apex/AccountsService.getOpportunitiesByAccountId';
import getContactList from '@salesforce/apex/AccountsService.getContactListByAccountId';

const columns = [
    {label: 'Name', fieldName: 'Name', type: 'text'},
    {label: 'Stage', fieldName: 'StageName', type: 'text'},
    {label: 'Amount', fieldName: 'Amount', type: 'currency', typeAttributes: { currencyCode: 'USD'}},
    /* {label: 'Confidence', fieldName: 'confidence', type: 'percent', cellAttributes:
    { iconName: { fieldName: 'trendIcon' }, iconPosition: 'right' }}, */
];

export default class AccountOpportunities extends LightningElement {
    
    @api recordId;
        
    columns = columns;
    
    @wire(getContactList, { accountId: '$recordId' }) contacts;
    
    @wire(getOpportunitiesByAccountId, { accountId: '$recordId' }) opportunities;
    
    constructor() {
        super();
        //alert('Hello');
    }
    /* changeHandler(event) {
        alert(event.target.value);
    } */
}
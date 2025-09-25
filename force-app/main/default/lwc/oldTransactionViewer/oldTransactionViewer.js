import {LightningElement, wire, api} from 'lwc';
import getBigRecordList from '@salesforce/apex/BigObjectController.getTransactionBigDataRecordsforContact';
  const columns = [
    { label: 'Id', fieldName: 'Id' },
    //{ label: 'Contact Id', fieldName: 'Contact__c'},
    { label: 'Transaction Date', fieldName: 'Transaction_Date__c'},
    { label: 'Amount', fieldName: 'Amount__c'},
    { label: 'UPI ID', fieldName: 'UPI_ID__c' },
    { label: 'Name', fieldName: 'Name__c'},
    { label: 'Created Date', fieldName: 'Created_DateTime__c'},
    { label: 'Type', fieldName: 'Type__c'},
    { label: 'Mode', fieldName: 'Mode__C'},
    { label: 'Transaction ID', fieldName: 'Transaction__c'},
];
export default class oldTransactionViewer extends LightningElement {
  columns = columns;
  @api recordId;
  @wire(getBigRecordList,{contactId :'$recordId'})
  bigRecords;
  get hasData(){
    return this.bigRecords.data;
  }
}
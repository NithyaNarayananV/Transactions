import {LightningElement, wire, api} from 'lwc';
import getBigRecordList from '@salesforce/apex/BigObjectController.getTransactionBigDataRecordsforContact';
  const columns = [
    { label: 'Id', fieldName: 'Id' },
    { label: 'Contact Id', fieldName: 'Contact__c'},
    { label: 'Amount', fieldName: 'Amount__c'},
    { label: 'Transaction Date', fieldName: 'Transaction_Date__c'},
    { label: 'UPI ID', fieldName: 'UPI_ID__c' },
    { label: 'Transaction ID', fieldName: 'Transaction__c'},
];
export default class oldTransactionViewer extends LightningElement {
  @api recordId;
  @wire(getBigRecordList,{contactId :'$recordId'})
  bigRecords;
sampleData =[{"Id":"1234", "Contact__c":"Test contact","Amount__c":"12345.2142","Transaction_Date__c":"Date","UPI_ID__c":"UPI ID@upi","Transaction__c":"TxnId"}];
  get hasData(){
    return this.bigRecords.data;
  }

}
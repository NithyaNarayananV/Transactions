import {LightningElement, wire, api} from 'lwc';
import getBigRecordList from '@salesforce/apex/BigObjectController.getTransactionBigDataRecordsforContact';
  const columns = [
    { label: 'Id', fieldName: 'Id' },
    //{ label: 'Contact Id', fieldName: 'Contact__c'},
    { label: 'Transaction Date', fieldName: 'Transaction_Date__c'},
    { label: 'Amount', fieldName: 'Amount__c'},
    { label: 'UPI ID', fieldName: 'Upi_Id__c' },
    { label: 'Name', fieldName: 'Name__c'},
    { label: 'Created Date', fieldName: 'CreatedDate'},
    { label: 'Type', fieldName: 'Type__c'},
    { label: 'Mode', fieldName: 'Mode__c'},
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
  get totalIncome(){
    let totalIncome = 0;
    if(this.bigRecords.data){
      this.bigRecords.data.forEach(record=>{
        if(record.Type__c === 'Income'){
          totalIncome += record.Amount__c;
        }
      });
    }
    return totalIncome; 
  }
  get totalExpense(){
    let totalExpense = 0;
    if(this.bigRecords.data){
      this.bigRecords.data.forEach(record=>{
        if(record.Type__c === 'Expense'){
          totalExpense += record.Amount__c;
        }
      });
    }
    return totalExpense; 
  }
  get balanceAmount(){
    return this.totalIncome - this.totalExpense;
  }
}
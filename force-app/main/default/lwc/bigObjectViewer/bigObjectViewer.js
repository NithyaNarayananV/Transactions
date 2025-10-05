import {LightningElement, wire, api, track} from 'lwc';
import getBigRecordList from '@salesforce/apex/BigObjectController.getTransactionBigDataRecords';
  const columns = [
  { label: 'Id',                value: 'Id',                fieldName: 'Id' },
  { label: 'Transaction Date', value: 'Transaction_Date__c', fieldName: 'Transaction_Date__c' },
  { label: 'Amount',           value: 'Amount__c',           fieldName: 'Amount__c' },
  { label: 'UPI ID',           value: 'Upi_Id__c',           fieldName: 'Upi_Id__c' },
  { label: 'Name',             value: 'Name__c',             fieldName: 'Name__c' },
  { label: 'Created Date',     value: 'CreatedDate',         fieldName: 'CreatedDate' },
  { label: 'Type',             value: 'Type__c',             fieldName: 'Type__c' },
  { label: 'Mode',             value: 'Mode__c',             fieldName: 'Mode__c' },
  { label: 'Transaction ID',   value: 'Transaction__c',      fieldName: 'Transaction__c' }
  ];

export default class bigObjectViewer extends LightningElement {
  columns = columns;
  FilterByOptions = columns;
  fullData=[]
  bigRecords=[]
  @track filteredData=[]
  timer
  @track filterBy;
  @wire(getBigRecordList)
  bigRecordHandler({data,error}){
    if(data){
      console.log('data : '+data);
      this.fullData = data
      this.bigRecords=data;
      this.filteredData=data;
    }
    if(error){
      console.log('Error : '+error);
    }
  }

  ///*/Sort Handler
  sortedBy = 'Name'
  sortDirection='asc'
  //this.bigRecords.data
  sortHandler(event){
    this.sortedBy = event.target.value;
    this.bigRecords = this.sortBy(this.bigRecords)
    console.log('Sorted by '+this.sortedBy)
  }
  sortBy(data){
   console.log('In sortBy method')
    const cloneData = [...data]
    cloneData.sort((a,b)=>{
      if(a[this.sortedBy]=== b[this.sortedBy]){
        return 0
      }
      return this.sortDirection === 'desc'?
      a[this.sortedBy] > b[this.sortedBy] ? -1:1 :
      a[this.sortedBy] < b[this.sortedBy] ? -1:1 
    })
    return cloneData
  }
  //*/
  filterbyHandler(event){
     this.filterBy = event.detail.value;
     console.log('Selected filter field:', this.filterBy);
     console.log('Selected filter event.detail.value;:', event.detail.value);
     console.log('Selected filter event.target.value;:', event.target.value);
     console.log('Selected filter event:', event);

  }

  filterHandler(event){
    const {value} = event.target
    window.clearTimeout(this.timer)
    if(value)
    {
      this.timer = window.setTimeout(()=>{
        console.log(value)
        this.filteredData = this.fullTableData.filter(eachObj=>{
          if(this.filterBy === 'All'){
            return Object.keys(eachObj).some(key=>{
              return eachObj[key].toLowerCase().includes(value)
            })
          } else {
            /**Below logic will filter only selected fields */
            const val = eachObj[this.filterBy] ? eachObj[this.filterBy]:''
            return val.toLowerCase().includes(value)
          }
        })
      }, 500)   
    } else {
      this.filteredData = [...this.fullTableData]
    }
  }
  get totalIncome(){
    let totalIncome = 0;
    if(this.bigRecords){
      this.bigRecords.forEach(record=>{
        if(record.Type__c === 'Income'){
          totalIncome += record.Amount__c;
        }
      });
    }
    return totalIncome; 
  }
  get totalExpense(){
    let totalExpense = 0;
    if(this.bigRecords){
      this.bigRecords.forEach(record=>{
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
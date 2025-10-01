import {LightningElement, wire, api, track} from 'lwc';
import getBigRecordList from '@salesforce/apex/BigObjectController.getTransactionBigDataRecords';
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

export default class bigObjectViewer extends LightningElement {
  columns = columns;
  FilterByOptions = columns;
  fullData=[]
  bigRecords=[]
  @track filteredData=[]
  timer
  filterBy="Name"
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

  /*/Sort Handler
  sortedBy = 'Name'
  sortDirection='asc'
  //this.bigRecords.data
  sortHandler(event){
    this.sortedBy = event.target.value;
    this.bigRecords = this.sortBy(this.bigRecords)
  }
  sortBy(data){
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
  }*/
  filterbyHandler(event){
    this.filterBy = event.target.value
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
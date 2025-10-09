import {LightningElement, wire, api, track} from 'lwc';
import getBigRecordList from '@salesforce/apex/BigObjectController.getTransactionBigDataRecords';
const columns = [
	{ label: 'Id',               value: 'Id',		             fieldName: 'Id' },
	{ label: 'Transaction Date', value: 'Transaction_Date__c', fieldName: 'Transaction_Date__c' },
	{ label: 'Amount',           value: 'Amount__c',           fieldName: 'Amount__c' },
	{ label: 'UPI ID',           value: 'Upi_Id__c',           fieldName: 'Upi_Id__c' },
	{ label: 'Name',             value: 'Name__c',             fieldName: 'Name__c' },
	// { label: 'Created Date',     value: 'CreatedDate',         fieldName: 'CreatedDate' },
	{ label: 'Type',             value: 'Type__c',             fieldName: 'Type__c' },
	{ label: 'Mode',             value: 'Mode__c',             fieldName: 'Mode__c' },
	//  { label: 'Transaction ID',   value: 'Transaction__c',      fieldName: 'Transaction__c' }
];

const columnsFilter = [
	{ label: 'Transaction Date', value: 'Transaction_Date__c', fieldName: 'Transaction_Date__c' },
	{ label: 'Amount',           value: 'Amount__c',           fieldName: 'Amount__c' },
	{ label: 'UPI ID',           value: 'Upi_Id__c',           fieldName: 'Upi_Id__c' },
	{ label: 'Name',             value: 'Name__c',             fieldName: 'Name__c' },
	{ label: 'Mode',             value: 'Mode__c',             fieldName: 'Mode__c' },
];
export default class bigObjectViewer extends LightningElement {
	columns = columns;
	FilterByOptions = columnsFilter;
	fullData=[]
	bigRecords=[]
	@track filteredData=[]
	timer
	@track filterBy='Name__c';
	sortedBy = 'Transaction_Date__c'
	sortDirection = 'desc'; // default value
	filterWord=null

	sortOptions = [
		{ label: 'Ascending', value: 'asc' },
		{ label: 'Descending', value: 'desc' }
	];
	selectedTransactionType='Both'
	typeOptions = [
		{ label: 'Income', value: 'Income' },
		{ label: 'Expense', value: 'Expense' },
		{ label: 'Both', value: 'Both' },
	];

	handleSortDirectionChange(event) {
		this.sortDirection = event.detail.value;
		this.filteredData = this.sortBy(this.filteredData)
		console.log('Sort direction changed to: ' + this.sortDirection);
	}
	@wire(getBigRecordList)
	bigRecordHandler({data,error}){
		if(data){
			console.log('data : '+data);
			this.fullData = data
			this.bigRecords=data;
			//this.filteredData=data;
			this.fullTableData=data;
			this.sortedBy = 'Transaction_Date__c'
			this.sortDirection = 'desc'; 
			this.filteredData = this.sortBy(data)

		}
		if(error){
			console.log('Error : '+error);
		}
	}

	///*/Sort Handler
	//this.bigRecords.data
	sortHandler(event){
		this.sortedBy = event.target.value;
		this.filteredData = this.sortBy(this.filteredData)
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

	handleTransactionTypeChange(event){
		this.selectedTransactionType=event.target.value;
		console.log(this.selectedTransactionType);
		if(this.selectedTransactionType=='Both'){
			console.log('Selected type is both : event : ',event);
		}
		else{
			this.filterBy ='Type__c';
			console.log('Inside else Both part : selectedTransactionType ,  event = ',this.selectedTransactionType, event);
			//event.target.value = selectedTransactionType ;
			this.filterTable(selectedTransactionType)
		}
	}
	filterbyHandler(event){
		this.filterBy = event.detail.value;	
		if(this.filterBy ==='Type__c'){
			this.displayTypeRadio=true;
		}
		console.log('Selected filter field:', this.filterBy);
		console.log('Selected filter event.detail.value;:', event.detail.value);
		console.log('Selected filter event.target.value;:', event.target.value);
		console.log('Selected filter event:', event);

	}
	filterTable(value){
		console.log('Inside filterTable : value : ',value);
		if(value)
		{
			console.log('inside 		if(value)')
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
			this.filteredData = this.sortBy(this.filteredData)

		} else {
		this.filteredData = [...this.fullTableData]
			this.filteredData = this.sortBy(this.filteredData)
		}
	}
		filterHandler(event){
			console.log('inside 	filterHandler(event){')
			const value = event.target.value;
			this.filterWord = true;
			window.clearTimeout(this.timer)
			this.filterTable(value);
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
	get filterIncome(){
		let Income = 0;
		if(this.filteredData){
		this.filteredData.forEach(record=>{
			if(record.Type__c === 'Income'){
			Income += record.Amount__c;
			}
		});
		}
		return Income;
	}
	get filterExpense(){
		let Expense = 0;
		if(this.filteredData){
		this.filteredData.forEach(record=>{
			if(record.Type__c === 'Expense'){
			Expense += record.Amount__c;
			}
		});
		}
		return Expense;
	}
	get filterAmount(){
		return this.filterIncome - this.filterExpense;
	}
}
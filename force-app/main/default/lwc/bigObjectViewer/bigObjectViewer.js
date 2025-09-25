import { LightningElement, wire } from 'lwc';
import getBigRecordList from '@salesforce/apex/BigObjectController.getTransactionBigDataRecords';
export default class bigObjectViewer extends LightningElement {

  @wire(getBigRecordList)
  bigRecords;

  get hasData(){
    return this.bigRecords?.data?.length>0;
  }
}
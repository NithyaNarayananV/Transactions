import {LightningElement, wire, api, track} from 'lwc';
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';
import {createRecord} from 'lightning/uiRecordApi';
import TRANSACTION_C_OBJECT from '@salesforce/schema/Transaction__c';
import NAME_FIELD from '@salesforce/schema/Transaction__c.Name';
import PAYMENT_MODE_C_FIELD from '@salesforce/schema/Transaction__c.Payment_Mode__c';
import RENT_AMOUTN_FIELD from '@salesforce/schema/Transaction__c.Rent_Amount__c';
import UPI_ID_FIELD from '@salesforce/schema/Transaction__c.UPI_ID__c';
import TYPE_C_FIELD from '@salesforce/schema/Transaction__c.Type__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Transaction__c.Description__c';
import PAID_DATE_FIELD from '@salesforce/schema/Transaction__c.Paid_Date__c';

export default class transactionRecordCreation extends LightningElement {
    @api paymentMode=''
    @api type=''
    @api amount=0.0
    @api transactionName=''
    isIncome=false
    isUpi=false
    upiId
    contactName=''
    paymentDate= new Date().toISOString().slice(0,10);
    timeNow = new Date();
    recordTypeId;
    paymentModePickList;
    typePickList;
    note;


    @wire(getObjectInfo,{objectApiName: TRANSACTION_C_OBJECT})
    onjectHandler({data}){
        if(data){
            this.recordTypeId=data.defaultRecordTypeId;
        }
    }

    @wire(getPicklistValues,{ recordTypeId:'$recordTypeId', fieldApiName: PAYMENT_MODE_C_FIELD })
    picklistHandlerPAYMENTMODE({data}){
        if(data){
            this.paymentModePickList=data.values;
            this.paymentMode = this.paymentModePickList[1].value;

        }
    }

    @wire(getPicklistValues,{ recordTypeId:'$recordTypeId', fieldApiName: TYPE_C_FIELD })
    picklistHandlerTYPE({data}){
        if(data){
            this.typePickList=data.values;
            this.typePickList=this.typePickList.slice(0,2);
            this.type = this.typePickList[1].value;
            //console.log(this.typePickList);
            this.updateTransactionName()
        }
    }

    amountHandler(event){
        console.log('Testing ');
        console.log('NAME_FIELD : ',NAME_FIELD);
        console.log('Testing');

        /*
        console.log('this.typePickList : ',this.typePickList);
        console.log('this.typePickList[0] : ',this.typePickList[0]);
        console.log('this.typePickList[0].value : ',this.typePickList[0].value);

        console.log('Date 09-Oct-2025 Time PM 01:04');
        console.log('onchange : amountHandler : event.detail : ',event.detail);
        console.log('onchange : amountHandler : paymentModePickList : ',this.paymentModePickList);
        console.log('onchange : amountHandler : objectInfo : ',this.objectInfo);
        */
        this.amount=event.detail.value;
        console.log('onchange : amountHandler : transactionName : ',this.transactionName);
        this.updateTransactionName()
    }
    updateTransactionName(){
        if(this.isIncome==true)
            this.transactionName='Cr - '+this.amount+' - ' +this.contactName;//+this.amount+'';
        else
            this.transactionName='Dt - '+this.amount+' - ' +this.contactName;//+this.amount+'';
    }
    typeChangeHandler(event){
        if(event.detail.value=='Income')
            this.isIncome=true
        else
            this.isIncome=false
        this.updateTransactionName()
    }
    modeChangeHandler(event){
        if(event.detail.value=='UPI')
            this.isUpi=true
        else
            this.isUpi=false
    }
    contactNameUpdate(event){
        this.contactName=event.detail.value;
        this.updateTransactionName()
    }
    noteHandler(event){
        this.note=event.detail.value;
    }
    saveHandler(){
        console.log('Suppoosed to Save the Record : Check for Record Save');
        const fields = {};
        console.log('Before FIELDS  : ',JSON.stringify(fields,null,2));

        fields[NAME_FIELD.fieldApiName]             = this.transactionName;
        fields[PAYMENT_MODE_C_FIELD.fieldApiName]   = this.paymentMode;
        fields[RENT_AMOUTN_FIELD.fieldApiName]      = this.amount;
        fields[UPI_ID_FIELD.fieldApiName]           = this.contactName;
        fields[TYPE_C_FIELD.fieldApiName]           = this.type;
        fields[DESCRIPTION_FIELD.fieldApiName]      = '$'+this.note;
        fields[PAID_DATE_FIELD.fieldApiName]        = this.paymentDate;
        console.log('After FIELDS  : ',JSON.stringify(fields,null,2));
        console.log('NAME_FIELD : ',NAME_FIELD);

        console.log('NAME_FIELD : ',NAME_FIELD);
        const recordInput = {
            apiName : TRANSACTION_C_OBJECT.objectApiName,
            fields
        };
        console.log('recordInput : ',recordInput);
        createRecord(recordInput)
            .then(record =>{
                console.log('Transaction Record Created with Id : ',record.id);
            })
            .catch(error=>{
                console.error('Error creating record : ',error);
                console.error('Error creating record : ',error.body.message);

            });
    }
}
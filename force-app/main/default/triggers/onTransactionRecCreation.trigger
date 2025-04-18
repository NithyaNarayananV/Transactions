trigger onTransactionRecCreation on Transaction__c (after insert) {
    // LookUp Contact in the Transaction Record
    // 1. Add contact to the transaction record
    //     1. Search for contact with UPI id - search in 4 column (dont use mobilephone)
    //       FAX
    /*    
    else txn.BankAccount__c ='001NS00000behFTYAY';
    txn.Paid_Date__c = System.today();
    txn.Rent_Amount__c = AmountValue;
    txn.UPI_ID__c = UPIid;    
    txn.RentMonth__c = System.today();
    if (TxnType == 'Cr') txn.Type__c = 'Income';// if its Credited - Checkbox will be Checked!
    else if (TxnType == 'Dt') txn.Type__c = 'Expense';
    else txn.Type__c = 'Balance';
    */         
    System.debug('Start');
    /*
    If the transaction record contains content in Description, separate Deconing needs to be done
UPI-CHANDRASEKAR  V-Q563099341@YBL-YESB0YBLUPI-439044524501-GROCERIES
UPI-HUNGERBOX-PAYTM-8774066@PAYTM-PYTM0123456-405131247325-HUNGERBOX ORDER  B
UPI-HUNGERBOX-PAYTM-8774066@PAYTM-YESB0PTMUPI-421248693162-HUNGERBOX ORDER  B | 0000421248693162
TYpe : UPI
Name : HUNGERBOX-PAYTM
UPI ID : 8774066@PAYTM
Ref No :421248693162 | 0000421248693162
    */
    List <Transaction__c> TList = [Select Id, Description__C, RefNo__c, Name, Maintenance__c, Payment_Mode__c, Paid_Date__c, Rent_Amount__c,UPI_ID__c, RentMonth__c, Type__c, Contact__c from Transaction__c where Id IN :Trigger.new];
    //if there is some thing in Description, then it is Uploaded from Inspector.
    for (Transaction__c Txn: TList){
        String UpiTemp = '';
        boolean IsContactTagged = false;
        if(Txn.Description__C!=null && Txn.RefNo__c !=null){
            if (Txn.Description__C.substring(0,3) == 'UPI'){
                //txn.name = ''+TxnType+' - '+AmountValue +' - '+ UPIid ;
                Txn.Payment_Mode__c = 'UPI';
                // UPI ID Extraction !! from - UPI-HUNGERBOX-PAYTM-8774066@PAYTM-YESB0PTMUPI-421248693162-HUNGERBOX ORDER  B
                Integer PositionAt = -1;
                PositionAt = Txn.Description__C.indexOf('@');
                if(PositionAt== -1)
                {
                    Txn.Description__C = 'Error | No @ is Found ' + Txn.Description__C;
                    update Txn;
                    continue;                       
                }
                Integer PositionFdash=PositionAt,PositionLdash=PositionAt;
                // 45 = -
                while(Txn.Description__C.charAt(PositionFdash) !=45 || Txn.Description__C.charAt(PositionLdash) !=45)
                { 
                    if ( Txn.Description__C.charAt(PositionFdash)!=45)PositionFdash-=1;                        
                    if ( Txn.Description__C.charAt(PositionLdash)!=45)PositionLdash+=1;  
                }  
                Txn.UPI_ID__c = Txn.Description__C.substring(PositionFdash+1,PositionLdash);               
                UpiTemp = Txn.Description__C.substring(PositionFdash+1,PositionAt);
                if (Txn.Rent_Amount__c!=null && Txn.Rent_Amount__c>0){Txn.Type__c = 'Income';} //Income                 
                else if (Txn.Maintenance__c!=null && Txn.Maintenance__c>0) //Expense
                {  Txn.Type__c = 'Expense';
                    Txn.Rent_Amount__c=Txn.Maintenance__c;//Moving Maintenance value to Rent Amount
                    Txn.Maintenance__c=null;
                }
                update Txn;
                system.debug('Txn Updated');
            }
        }
        else if (Txn.UPI_ID__c!=null)
        {UpiTemp = Txn.UPI_ID__c.substring(0,Txn.UPI_ID__c.indexOf('@'));}                            

        System.debug('Before Contact Connect');
        if(Txn.UPI_ID__c!= null){
            system.debug('Inside UPI not null');
            if(Txn.UPI_ID__c.contains('Groww'))
            {
                Txn.Contact__c = '003NS00000FwzKFYAZ';
                IsContactTagged = true;
                Update Txn;
                System.debug('Txn Updated');
            }                
            else{        
                //string LikeTemp = '\'%'+UpiTemp+'%\'';
                List<contact> Con = [Select Id, Description from contact];// where Description LIKE :LikeTemp ];// where (FAX == UPIid or HomePhone = UPIid or OtherPhone = UPIid or Phone = UPIid or AssistantPhone = UPIid)];
                for (Contact C : Con){
                    //if (C.Fax == Txn.UPI_ID__c || C.HomePhone == Txn.UPI_ID__c || C.OtherPhone == Txn.UPI_ID__c || C.Phone == Txn.UPI_ID__c || C.AssistantPhone == Txn.UPI_ID__c){
                    //for (String D : C.Description )
                    if (Txn.UPI_ID__c.contains('@'))
                    UpiTemp = (UpiTemp=='')? Txn.UPI_ID__c.substring(0,Txn.UPI_ID__c.indexOf('@')):UpiTemp;
                    else
                    UpiTemp = (UpiTemp=='')? Txn.UPI_ID__c:UpiTemp;
                    if(C.Description!=null)
                        if(C.Description.contains(UpiTemp)==true)
                        {    
                            Txn.Contact__c = ''+C.Id; // If contact already Exist, Contact Id will be added to Transaction Record. 
                            IsContactTagged = true;
                            Update Txn;
                            System.debug('Txn Updated | '+C.Description+' || '+UpiTemp+' || Full =  \\ '+ Txn.UPI_ID__c);
                            //to update amount field in contact
                            if(Txn.Type__c == 'Income')                                 
                                ContactAmountUpdation.AmountUpdate2Contact( ''+C.Id, Txn.Rent_Amount__c, 0);
                            else if(Txn.Type__c == 'Expense')                                 
                                ContactAmountUpdation.AmountUpdate2Contact( C.Id, 0,Txn.Rent_Amount__c);
                            break;
                        }
                }
            }
            //If Contact is not already present in System (UPI), New contact will be created with UPI id.
            if(!IsContactTagged){
                Contact Cnew = new Contact();
                Cnew.Description='\''+Txn.UPI_ID__c+'\',';
                //Cnew.HomePhone = Txn.UPI_ID__c;
                Cnew.LastName = ''+UpiTemp;
                Insert Cnew; // New contact is Inserted
                system.debug('Contact Details will be added to the Transaction record.');
                Txn.Contact__c = ''+Cnew.Id;// Contact Details is added to the Transaction record.
                if(Txn.Type__c == 'Income')                                 
                    ContactAmountUpdation.AmountUpdate2Contact( ''+Cnew.Id, Txn.Rent_Amount__c, 0);
                else if(Txn.Type__c == 'Expense')                                 
                    ContactAmountUpdation.AmountUpdate2Contact( Cnew.Id, 0,Txn.Rent_Amount__c);
                            
                if(Txn.Contact__c == null)
                {
                    system.debug('Contact is NUll');
                    //system.debug('Contact is NUll');
                    Txn.Description__C+=Cnew.Id+'>>';
                }
                update Txn;
            } 
            //to update amount field in contact
            //AmountUpdate2Contact(String ConId, Decimal Income, Decimal OutGoing)
                
            System.debug('B4 Big Object');
            
            
            //Call the method in TargetClass and pass parameters
            if(Txn.Contact__c == null)
            {system.debug('Contact is NUll');}
            else 
                createRecordOnTxnBigObject.receiveParameters(Txn.id,Txn.Contact__c, Txn.Name, Txn.Paid_Date__c, Txn.Rent_Amount__c,Txn.UPI_ID__c);
            try{
                Case C = [Select CaseNumber, Status from case where CaseNumber = :Txn.Description__C ];// where (FAX == UPIid or HomePhone = UPIid or OtherPhone = UPIid or Phone = UPIid or AssistantPhone = UPIid)];
                system.debug(c);
                //for(Case c : Cc){
                
                if (c.CaseNumber == Txn.Description__C){
                    c.Status = 'Closed';
                    IsContactTagged= true;
                    System.debug(c.Status + '  | This record should be in Closed state');
                    update c;
                    //If Case is Closed, then it can be deleted for storage saving.
                    if (c.status == 'Closed')
                        masterFuture.deleteCase(''+c.id);                    
                    //c.IsDeleted = true;
                    //System.debug('Case Deleted');
                    //delete  c;
                    //break;
                    //}
                }
            }
            catch (DmlException e) {
                System.debug('Error : Case detilas issue ' + e.getMessage());
                //if error - status should be escalated
                //c.status = 'Escalated';
                //c.Description = '< Transaction Record Could not be Created. Error Meassage : '+ e.getMessage() +'  > ' + c.Description;
                //update c;
            }
                
            //update Cc;
            //System.debug('CC Update');
        }
    }
}
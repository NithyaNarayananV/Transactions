trigger onTransactionRecCreation on Transaction__c (after insert) {
    // LookUp Contact in the Transaction Record
    // 1. Add contact to the transaction record
    //     1. Search for contact with UPI id - search in 4 column (dont use mobilephone)
    //       FAX
    System.debug('Start');
    /*
    If the transaction record contains content in Description, separate Deconing needs to be done
    */
    List <Transaction__c> TList = [Select Id, Description__C, RefNo__c, Name, BankAccount__c, Maintenance__c, Payment_Mode__c, Paid_Date__c, Rent_Amount__c,UPI_ID__c, RentMonth__c, Type__c, Contact__c from Transaction__c where Id IN :Trigger.new];
    //if there is some thing in Description, then it is Uploaded from Inspector.
    for (Transaction__c Txn: TList){
        String UpiTemp = '';
        boolean IsContactTagged = false;
        if(Txn.Description__C!=null && Txn.RefNo__c !=null){
            if (Txn.Description__C.substring(0,3) == 'UPI'){
                //txn.name = ''+TxnType+' - '+AmountValue +' - '+ UPIid ;
                Txn.Payment_Mode__c = 'UPI';
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
                string contactName = Txn.Description__C.substring(9, txn.Description__C.indexOf('#',9));
                if(contactName == 'Not Found' || contactName == null || contactName == '')
                    Cnew.LastName = ''+UpiTemp;
                else
                    Cnew.LastName = contactName;
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
                String caseNo = Txn.Description__C.substring(0, 8);
                Case C = [Select CaseNumber, Status from case where CaseNumber = :caseNo ];// where (FAX == UPIid or HomePhone = UPIid or OtherPhone = UPIid or Phone = UPIid or AssistantPhone = UPIid)];
                system.debug(c);                
                if (c.CaseNumber == Txn.Description__C){
                    c.Status = 'Closed';
                    IsContactTagged= true;
                    System.debug(c.Status + '  | This record should be in Closed state');
                    update c;
                    if (c.Status == 'Closed')
                        masterFuture.deleteCase(''+c.id);
                }
            }
            catch (DmlException e) {
                System.debug('Error : Case detilas issue ' + e.getMessage());
            }
        }
        else if (Txn.Type__c == 'Balance')
        {
            Account AccUpdate = [Select Id, Balance__c from Account where id = :Txn.BankAccount__c ];// where (FAX == UPIid or HomePhone = UPIid or OtherPhone = UPIid or Phone = UPIid or AssistantPhone = UPIid)];
            AccUpdate.Balance__c =   Txn.Rent_Amount__c;
            update AccUpdate;
            try{
                Case C = [Select CaseNumber, Status from case where CaseNumber = :Txn.Description__C ];// where (FAX == UPIid or HomePhone = UPIid or OtherPhone = UPIid or Phone = UPIid or AssistantPhone = UPIid)];
                system.debug(c);
                if (c.CaseNumber == Txn.Description__C){
                    masterFuture.deleteCase(''+c.id);
                    masterFuture.deleteTxn(''+Txn.id);
                }
            }
            catch (DmlException e) {
                System.debug('Error : Case detilas issue ' + e.getMessage());
            }
        }
    }
}
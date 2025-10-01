public class contactTag implements Queueable {
    private List<Id> accountIds;
	//   public static void contactTag( List<String> upiIdList, List<String> conNameList, List<String> txnIdList){
	private List<String> upiIdList = new List<String>(); // UPI ID list
    private List<String> conNameList = new List<String>(); //Contact Name
    private List<String> txnIdList = new List<String>(); // Transaction Id from main class

    List<Transaction__c> TList = new List<Transaction__c>(); // Transaction list
    List<Transaction__c> TRestList = new List<Transaction__c>(); // Transaction list

   	List<Transaction__c> TnewConList = new List<Transaction__c>(); // Transaction list
    List<Transaction__c> TnotTaggedList = new List<Transaction__c>(); // Transaction list

    private List<Contact> Con = new List<Contact>();// [Select Id, LastName, Description, InComing__c, OutGoing__c , Balance__c from contact Limit 10000];
    private Map<Id, Contact> contactMap = new Map<Id, Contact>();
    private List<String> newConUpiId = new List<String>(); // to hav new upiid alone
    private Map<String,Integer> indexConNew = new Map<String,Integer>();// to have UPIID and index of new contact created.
    private Integer indexCon = 0;
    private Map<String,String> newUpiAndConId = new Map<String,String>();//to New upiid and its future contact id.
    private List<Contact> ConNew = new List<Contact>() ;
    private List<Contact> ConNewUpdate = new List<Contact>() ;
    private Integer index = 0;
    private String upiIdTemp='';
    
    public contactTag(List<String> upiIdList, List<String> conNameList, List<String> txnIdList, List<String> ConCondition){
        system.debug('Testing inside Constructor');
        String query  = 'SELECT Id, LastName, Description, Upi_Ids__c, InComing__c, OutGoing__c , Balance__c FROM contact WHERE ';
        query+=string.join(ConCondition, ' OR ');
        system.debug('contactTag > contactTag > Contact Query : '+query);

 		this.Con = Database.query(query);
        system.debug('contactTag | Query = '+query);
		system.debug('contactTag | this.con = '+this.Con);
        system.debug('contactTag | this.con length = '+this.Con.size());

        this.upiIdList=upiIdList;
		this.conNameList=conNameList;
        this.txnIdList=txnIdList;
    }
    public contact ContactAmountUpdation(contact c)
    {       
        if(TList[index].Type__c == 'Income'){
            if (C.InComing__c == null) 
                C.InComing__c = TList[index].Rent_Amount__c;
            else
                C.InComing__c +=TList[index].Rent_Amount__c;
            C.Balance__c = (C.Balance__c == null) ? TList[index].Rent_Amount__c : (C.Balance__c + TList[index].Rent_Amount__c);
		}else if(TList[index].Type__c == 'Expense'){// ContactAmountUpdation.AmountUpdate2Contact( C.Id, 0,TList[index].Rent_Amount__c);
              if (C.OutGoing__c == null)
                  C.OutGoing__c = TList[index].Rent_Amount__c;
              else
                  C.OutGoing__c +=TList[index].Rent_Amount__c;
              C.Balance__c = (C.Balance__c == null) ? -TList[index].Rent_Amount__c : (C.Balance__c - TList[index].Rent_Amount__c);
		}
        return c;
    }
    public contact ContactAmountUpdation(contact c, Integer Income , Integer Expense){
        if(Income != 0){
            if (C.InComing__c == null) 
                C.InComing__c = Income;
            else
                C.InComing__c +=Income;
            C.Balance__c = (C.Balance__c == null) ? Income : (C.Balance__c + Income);
		}else if(Expense != 0){// ContactAmountUpdation.AmountUpdate2Contact( C.Id, 0,TList[index].Rent_Amount__c);
              if (C.OutGoing__c == null)
                  C.OutGoing__c = Expense;
              else
                  C.OutGoing__c += Expense;
              C.Balance__c = (C.Balance__c == null) ? -Expense : (C.Balance__c -Expense);
		}
        return c;
    }
    public void NewContactCreation(){
        Contact Cnew = new Contact();
        //Cnew.Description='\''+TList[index].UPI_ID__c+'\',';
        Cnew.Upi_ids__c=''+TList[index].UPI_ID__c+',';
        //Cnew.HomePhone = Txn.UPI_ID__c;
        if(conNameList[index] == 'Not Found' || conNameList[index] == null || conNameList[index] == '')
            Cnew.LastName = ''+UpiIdTemp;
        else
            Cnew.LastName = conNameList[index];
        ConNew.add(Cnew);
        newConUpiId.add(TList[index].UPI_ID__c);
        newUpiAndConId.put(TList[index].UPI_ID__c,''+index);
        indexConNew.put(TList[index].UPI_ID__c,indexCon);
    }

    public void execute(QueueableContext context) {
        system.debug('Testing inside execute');
        TList = [Select Id, Description__C, RefNo__c, Name, BankAccount__c, Payment_Mode__c, Paid_Date__c, Rent_Amount__c,UPI_ID__c, Type__c, Contact__c from Transaction__c where Id IN :txnIdList];
    	////From Future Method    
        system.debug('contactTag | execute | Queueable is running');
        
        for ( String upiId: upiIdList){
            if(txnIdList[index]!='Failed' && upiId !=null){//only working on the Txn records that are saved into database.
                system.debug('inside => if(txnIdList[index]!=\'Failed\'){//only working on the Txn records that are saved into database.');
                //################### Work here!!!
                if(upiId.contains('@'))// UPI ID is present
                    upiIdTemp = upiId.substring(0,upiId.indexOf('@'));
                else 
                    upiIdTemp = upiId;
                    
                Boolean IsContactTagged = false;
                system.debug('contactTag > execute > upiIdTemp : '+upiIdTemp);
                system.debug('contactTag > execute > BEFORE > for(Contact c:con) > con : '+con);
                for(Contact c:con){
                    system.debug('contactTag > execute > for(Contact c:con) > START >  c : '+c);
                    if( (C.Description!=null && C.Description.contains(upiIdTemp)==true) ||  (C.Upi_Ids__c!=null &&C.Upi_Ids__c.contains(upiIdTemp)==true )){    
                        system.debug('contactTag > execute > for(Contact c:con) >  Inside If');
                        TList[index].Contact__c = ''+C.Id; // If contact already Exist, Contact Id will be added to Transaction Record. 
                        IsContactTagged = true;
                        System.debug('Txn Updated | '+C.Description+' || '+upiIdTemp+' || Full =  \\ '+ TList[index].UPI_ID__c);
                        //to update amount field in contact
                        c=ContactAmountUpdation(c);
                        TRestList.add(TList[index]);
                        break;
                    }
                }
                if(!IsContactTagged){
                    /*
                    1. Create contact,
                    2. Add it to a common list 
                    3. Insert the contact	
                    4. after that, update the transaction with the new contact ID in bulk
                    */
                    if (newConUpiId.contains(TList[index].UPI_ID__c)) {
                        System.debug('Contact is not present, but previos record have this contact.');
                        TnotTaggedList.add(TList[index]);
                    } else {
                        TnewConList.add(TList[index]);
                        NewContactCreation();
                        indexCon++;
                    }
                }
            }else {//if the respesctive Txn is Failed to save ito adtabase
                system.debug('Else of if(txnIdList[index]!=\'Failed\')');
            }
            index++;
        }      
        if(ConNew.size()>0){
            Database.SaveResult[] results = Database.insert(ConNew,false);
            for (Integer i =0; i<results.size(); i++){
                if(results[i].isSuccess()){
                    System.debug('Success record : '+ConNew[i].Id);
                    newUpiAndConId.put(newConUpiId[i],''+ConNew[i].Id);
                    indexConNew.put(''+ConNew[i].Id,indexConNew.get(''+newConUpiId[i])); //this will fetch the index using the upi id and tag it corresponding to contact id
                }
                if(!results[i].isSuccess()){System.debug('Failed record : '+ConNew[i]);}
            }
            system.debug('Contacts has been created!');
        }
        else
            system.debug('No Contact to create!');  
            
		contactMap = new Map<Id, Contact>(ConNew);
        //Need to update Transaction and Contact
        // 
        //ConNewUpdate & TList
        index = 0;
        for ( String upiId: newConUpiId){
            system.debug('inside =>         for ( String upiId: newConUpiId){');
            TnewConList[index].Contact__c = ''+newUpiAndConId.get(upiId); // If contact already Exist, Contact Id will be added to Transaction Record.  | but its not getting added correctly as expected!
            //IsContactTagged = true;
            System.debug('Txn TnewConList[index].Contact__c | '+TnewConList[index].Contact__c);
            //to update amount field in contact
            ConNew[index]=ContactAmountUpdation(ConNew[index], (TnewConList[index].Type__c == 'Income')? Integer.valueOf(TnewConList[index].Rent_Amount__c) :   0 , (TnewConList[index].Type__c == 'Expense')? Integer.valueOf(TnewConList[index].Rent_Amount__c) : 0   );            
            index++;       
        } 
        for(Transaction__c Tn: TnotTaggedList){
            Tn.Contact__c = ''+newUpiAndConId.get(Tn.UPI_ID__c);
            System.debug('Txn TnotTaggedList Contact__c | '+Tn.Contact__c);
            //to update amount field in contact
            ConNew[indexConNew.get(Tn.Contact__c)] = ContactAmountUpdation(ConNew[indexConNew.get(Tn.Contact__c)], (Tn.Type__c == 'Income')? Integer.valueOf(Tn.Rent_Amount__c) : 0 , (Tn.Type__c == 'Expense')? Integer.valueOf(Tn.Rent_Amount__c) : 0 );
        }
        //Now update the Transaction and Contact
        system.debug('Now update the Transaction and Contact');
        if (TRestList.size()>0)		    {
            Database.SaveResult[] resultsTxn	        = Database.update(TRestList			,false);
            if(resultsTxn.size()>0) {
                for (Integer i =0; i<resultsTxn.size(); i++){
                    if(resultsTxn[i].isSuccess()){
                        System.debug('TRestList > Success record : '+TRestList[i].Id);
                    }
                    if(!resultsTxn[i].isSuccess()){System.debug('TRestList > Failed record : '+TRestList[i]);}
                }
            }
        } 
        if (TnewConList.size()>0) 	{
            Database.SaveResult[] resultsNewTxn        = Database.update(TnewConList	,false);
            if(resultsNewTxn.size()>0) {
                for (Integer i =0; i<resultsNewTxn.size(); i++){
                    if(resultsNewTxn[i].isSuccess()){
                        System.debug('TnewConList > Success record : '+TnewConList[i].Id);
                    }
                    if(!resultsNewTxn[i].isSuccess()){System.debug('TnewConList > Failed record : '+TnewConList[i]);}
                }
            }
        }            
		if (ConNew.size()>0) 	{
             Database.SaveResult[] resultsCon 	        = Database.update(ConNew		,false);
            if(resultsCon.size()>0) {
                for (Integer i =0; i<resultsCon.size(); i++){
                    if(resultsCon[i].isSuccess()){
                        System.debug('ConNew > Success record : '+ConNew[i].Id);
                    }
                    if(!resultsCon[i].isSuccess()){System.debug('ConNew > Failed record : '+ConNew[i]);}
                }
            }
        }	
        if (TnotTaggedList.size()>0) {
            Database.SaveResult[] resultsNotTaggedTxn  = Database.update(TnotTaggedList,false);
            if(resultsNotTaggedTxn.size()>0) {
                for (Integer i =0; i<resultsNotTaggedTxn.size(); i++){
                    if(resultsNotTaggedTxn[i].isSuccess()){
                        System.debug('TnotTaggedList > Success record : '+TnotTaggedList[i].Id);
                    }
                    if(!resultsNotTaggedTxn[i].isSuccess()){System.debug('TnotTaggedList > Failed record : '+TnotTaggedList[i]);}
                }
            }
        }
        system.debug('Done with things -> please dont throw any error yaar');
        system.debug('contactTag > execute > BEFORE > Id jobId = system.enqueueJob(new CreateTxnBigObjectQueuable(this.txnIdList));');
        Id jobId = system.enqueueJob(new CreateTxnBigObjectQueuable(this.txnIdList));
        system.debug('contactTag > execute > AFTER > enqueueJob > jobId : '+jobId);
        system.debug('contactTag > execute > END');
		//ENd From Future Method
    }
}

/*

To Bring Clarity!
1. Single Transactions with existing Contact
2. Single Transactions with New Contact
3. Multiple Transactions with existing Contact
4. Multiple Transactions with New Contact
5. Single Transaction with New Contact but Contact is created in the same batch for previous transaction.
this is the Complex situation


*/
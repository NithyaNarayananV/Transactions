public class contactTag implements Queueable {
    private List<Id> accountIds;
	//   public static void contactTag( List<String> upiIdList, List<String> conNameList, List<String> txnIdList){
	private List<String> upiIdList = new List<String>(); // UPI ID list
    private List<String> conNameList = new List<String>(); //Contact Name
    private List<String> txnIdList = new List<String>(); // Transaction Id from main class
    List<Transaction__c> TList = new List<Transaction__c>(); // Transaction list
    private List<Contact> Con = [Select Id, LastName, Description, InComing__c, OutGoing__c , Balance__c from contact Limit 10000];
    private Map<Id, Contact> contactMap = new Map<Id, Contact>();
    private List<String> newConUpiId = new List<String>(); // to hav new upiid alone
    private Map<String,String> newUpiAndConId = new Map<String,String>();//to New upiid and its future contact id.
    private List<Contact> ConNew = new List<Contact>() ;
    private List<Contact> ConNewUpdate = new List<Contact>() ;
    private Integer index = 0;
    private String upiIdTemp='';
    
    public contactTag(List<String> upiIdList, List<String> conNameList, List<String> txnIdList){
        system.debug('Testing inside Constructor');
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
    public void NewContactCreation(){
        Contact Cnew = new Contact();
        Cnew.Description='\''+TList[index].UPI_ID__c+'\',';
        //Cnew.HomePhone = Txn.UPI_ID__c;
        if(conNameList[index] == 'Not Found' || conNameList[index] == null || conNameList[index] == '')
            Cnew.LastName = ''+UpiIdTemp;
        else
            Cnew.LastName = conNameList[index];
        ConNew.add(Cnew);
        newConUpiId.add(TList[index].UPI_ID__c);
        newUpiAndConId.put(TList[index].UPI_ID__c,' ');  
        
		if(ConNew.size()>0)
        {
            Database.SaveResult[] results = Database.insert(ConNew,false);
            for (Integer i =0; i<results.size(); i++){
                if(results[i].isSuccess()){
                    System.debug('Success record : '+ConNew[i].Id);
                    newUpiAndConId.put(newConUpiId[i],''+ConNew[i].Id);
                }
                if(!results[i].isSuccess()){
                    System.debug('Failed record : '+ConNew[i]);
                }
            }
            //Contacts has been created!
            system.debug('Contacts has been created!');
        }
        else
            system.debug('No Contact to create!');     
        contactMap = new Map<Id, Contact>(ConNew);
    }
    
    
    public void execute(QueueableContext context) {
        system.debug('Testing inside execute');
        TList = [Select Id, Description__C, RefNo__c, Name, BankAccount__c, Maintenance__c, Payment_Mode__c, Paid_Date__c, Rent_Amount__c,UPI_ID__c, RentMonth__c, Type__c, Contact__c from Transaction__c where Id IN :txnIdList];
    	////From Future Method    
        system.debug('contactTag | execute | Queueable is running');
        
        for ( String upiId: upiIdList){            
            if(txnIdList[index]!='Failed'){//only working on the Txn records that are saved into database.
                system.debug('inside => if(txnIdList[index]!=\'Failed\'){//only working on the Txn records that are saved into database.');
                //################### Work here!!!
                upiIdTemp = upiId.substring(0,upiId.indexOf('@'));
                Boolean IsContactTagged = false;
                for(Contact c:con){
                    if(C.Description.contains(upiIdTemp)==true){    
                        system.debug('Inside For If');
                        TList[index].Contact__c = ''+C.Id; // If contact already Exist, Contact Id will be added to Transaction Record. 
                        IsContactTagged = true;
                        System.debug('Txn Updated | '+C.Description+' || '+upiIdTemp+' || Full =  \\ '+ TList[index].UPI_ID__c);
                        //to update amount field in contact
                        c=ContactAmountUpdation(c);
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
                    if (newConUpiId.contains(TList[index].UPI_ID__c))
                        System.debug('Contact is not present, but previos record have this contact.');
                    else NewContactCreation();
                }
            }else{//if the respesctive Txn is Failed to save ito adtabase
                system.debug('Else of if(txnIdList[index]!=\'Failed\')');
            }
            index++;
        }        
        //Time to Create a newContacts in Bulk
        if(ConNew.size()>0)
        {
            //Now transaction record needs to be tagged and contact needs to be updated with amount info;
            for ( String upiId: upiIdList){            
                system.debug('Inside  : for ( String upiId: upiIdList){  ');
                //newUpiAndConId
                TList[index].Contact__c = ''+ newUpiAndConId.get(upiId);
				// below express is similar to this c=ContactAmountUpdation(c);
				// updating the contact with the latest transaction amount and giving back to the map for updating it later
                contactMap.put(TList[index].Contact__c,ContactAmountUpdation(contactMap.get(TList[index].Contact__c)));
            }
        }
        
        //Need to update Transaction and Contact
            //ConNewUpdate & TList
        Database.SaveResult[] resultsTxn = Database.update(TList,false);
		Database.SaveResult[] resultsCon = Database.update(ConNewUpdate,false);
        system.debug('Done with things -> please dont throw any error yaar');
    	//ENd From Future Method
    }
}
/*
public class QueueableDemoClass implements Queueable {
    private List<Id> accountIds;
    
    // Constructor to pass account IDs
    public QueueableDemoClass(List<Id> accIds) {
        this.accountIds = accIds;
    }
    
    // Execute method to perform the operation
    public void execute(QueueableContext context) {
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
        for (Account acc : accounts) {
            acc.Name = acc.Name + ' - Updated with queueable';
        }
        update accounts;
    }
}

// Enqueue the job
List<Id> accountIds = new List<Id>();
for (Account acc : [SELECT Id FROM Account WHERE CreatedDate = TODAY]) {
    accountIds.add(acc.Id);
}
Id jobId = System.enqueueJob(new QueueableDemoClass(accountIds));
*/
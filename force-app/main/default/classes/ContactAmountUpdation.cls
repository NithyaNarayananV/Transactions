//public with sharing class ContactAmountUpdation {
 //   public ContactAmountUpdation() {

//    }
//}
public class ContactAmountUpdation {
    /*
    This class is to update the Amount fields in the Contact Record.
    This will be called when a 
    1. Transcation Record is Created
  */
    
  public static void amountUpdate2Contact(String conId, Decimal income, Decimal outGoing){
        Contact C = [Select Id, OutGoing__c, Balance__c, InComing__c from contact where id = :ConId LIMIT 1];
        if(Income==0) // So we need to update outgoing Field in Contact
        { 
            if (C.OutGoing__c == null)
                C.OutGoing__c = OutGoing;
            else
                C.OutGoing__c +=OutGoing;
            C.Balance__c = (C.Balance__c == null) ? -OutGoing : (C.Balance__c - OutGoing);            
        }   
        else if(OutGoing==0) // So we need to update Field in Contact
        {
            if (C.InComing__c == null)
                C.InComing__c = Income;
            else
                C.InComing__c +=Income;
            C.Balance__c = (C.Balance__c == null) ? Income : (C.Balance__c + Income);  
            
        }
        else
        {
            system.debug('Something Wrong | Income or Outgoing should be Zero | Income = '+Income+' | OutGoing = '+outgoing);
        }
        update C;
         system.debug('C updated');

        
    }


}
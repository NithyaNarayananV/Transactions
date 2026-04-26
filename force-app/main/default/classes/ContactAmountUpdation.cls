public class ContactAmountUpdation {
    /*
    This class is to update the Amount fields in the Contact Record.
    This will be called when a Transaction Record is Created
    */
    
    public static void amountUpdate2Contact(String conId, Decimal income, Decimal outGoing) {
        if (String.isBlank(conId) || (income == 0 && outGoing == 0)) {
            return;
        }
        
        Contact c = [SELECT Id, OutGoing__c, Balance__c, InComing__c FROM Contact WHERE Id = :conId LIMIT 1];
        
        if (c == null) {
            return;
        }
        
        if (income == 0 && outGoing > 0) {
            // Update outgoing field
            c.OutGoing__c = (c.OutGoing__c == null) ? outGoing : (c.OutGoing__c + outGoing);
            c.Balance__c = (c.Balance__c == null) ? -outGoing : (c.Balance__c - outGoing);            
        } else if (outGoing == 0 && income > 0) {
            // Update incoming field
            c.InComing__c = (c.InComing__c == null) ? income : (c.InComing__c + income);
            c.Balance__c = (c.Balance__c == null) ? income : (c.Balance__c + income);  
        } else {
            // Both values set - error condition
            System.debug('Invalid input: Both income and outgoing are non-zero. Income=' + income + ', OutGoing=' + outGoing);
            return;
        }
        
        try {
            update c;
        } catch (DmlException e) {
            System.debug('Error updating contact: ' + e.getMessage());
        }
    }
}
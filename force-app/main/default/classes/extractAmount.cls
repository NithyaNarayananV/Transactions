//public with sharing class extractAmount {
 //   public extractAmount() {
        public class ExtractAmount {  // From VS Code - change 1
            public static List<Decimal> amountExtraction(String mailBody, Integer positionRs, Decimal amountValue){
                /*
                 * if(mailBody.contains('Rs.')==true)
                {
                    PositionRs = mailBody.indexOf('Rs.');
                    PositionRs+=3;
            */            
                integer i=0;
                
                for( i= positionRs; i<positionRs+10; i++)
                {
                    System.debug(mailBody.charAt(i) +' = ' +String.fromCharArray( new List<integer> { mailBody.charAt(i) } ));
                    //44 = , //46 = . //48 = 0  //57 = 9
                    if(mailBody.charAt(i)==44)
                        {continue;}
                    if(mailBody.charAt(i)>47 && mailBody.charAt(i)<58)
                    {
                        AmountValue*=10;
                        AmountValue+=mailBody.charAt(i) - 48;
                    }                
                    //System.debug(mailBody.charAt(PositionRs));
                    if(mailBody.charAt(i)==46)
                    { 
                        PositionRs = i+1;
                        break;
                    }
                }
                //IsDecimal = true;
                //Decimal addition (2 point) 
                AmountValue *=100;
                AmountValue += (mailBody.charAt(PositionRs) - 48)*10 + (mailBody.charAt(PositionRs+1) - 48);
                AmountValue /=100;
                System.debug('Amount = '+AmountValue + (mailBody.charAt(PositionRs) - 48)/10 + (mailBody.charAt(PositionRs+1) - 48)/100);
                //decimal places
                
                Decimal[] arrayOfValue = new List<Decimal>();
                arrayOfValue.add(AmountValue);
                arrayOfValue.add(PositionRs);
                return arrayOfValue;
            }
        //}

   // }
}
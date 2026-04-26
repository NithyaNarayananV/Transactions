public class extractAmount {
    
    public static List<Decimal> amountExtraction(String mailBody, Integer positionRs, Decimal amountValue) {
        if (String.isBlank(mailBody) || positionRs == null || positionRs < 0) {
            return new List<Decimal> { 0, 0 };
        }
        
        // Use regex for more efficient amount extraction
        Pattern amountPattern = Pattern.compile('\\d{1,3}(,\\d{3})*' + '(\\.' + '\\d{2})?');
        Matcher matcher = amountPattern.matcher(mailBody);
        
        Decimal extractedAmount = 0;
        Integer position = positionRs;
        
        try {
            // Character-by-character parsing with bounds checking
            for (Integer i = positionRs; i < Math.min(positionRs + 10, mailBody.length()); i++) {
                Integer charCode = mailBody.charAt(i);
                
                // 44 = comma, 46 = period, 48-57 = digits
                if (charCode == 44) {
                    // Skip comma
                    continue;
                } else if (charCode >= 48 && charCode <= 57) {
                    // Digit found
                    extractedAmount = extractedAmount * 10 + (charCode - 48);
                } else if (charCode == 46) {
                    // Decimal point
                    position = i + 1;
                    break;
                } else {
                    // Non-digit, non-decimal character
                    break;
                }
            }
            
            // Add decimal places
            if (position < mailBody.length() - 1) {
                extractedAmount = extractedAmount * 100;
                Decimal tens = mailBody.charAt(position) - 48;
                Decimal ones = mailBody.charAt(position + 1) - 48;
                extractedAmount += tens * 10 + ones;
                extractedAmount = extractedAmount / 100;
            }
        } catch (Exception e) {
            System.debug('Error extracting amount: ' + e.getMessage());
            return new List<Decimal> { 0, position };
        }
        
        return new List<Decimal> { extractedAmount, position };
    }
}
public class N_CalloutClass {
    public static void CallOut(){
        // Define the API endpoint and API key
        String url = 'https://stock.indianapi.in/stock?name=Tata+Steel';
        String apiKey = 'Check Whatsapp with key = 78943hisw4jfe843khd89';

        
        // Create the HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setHeader('X-Api-Key', apiKey);
        
        // Send the HTTP request
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        // Process the response
        if (response.getStatusCode() == 200) {
            System.debug(response.getBody()); // Prints the response body to the debug log
        } else {
            System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
        }
    

    }
    
}
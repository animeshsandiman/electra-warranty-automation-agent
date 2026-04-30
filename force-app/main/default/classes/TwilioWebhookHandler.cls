@RestResource(urlMapping='/twilio/webhook/*')
global class TwilioWebhookHandler {
    
    @HttpPost
    global static void handleIncoming() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String body = req.requestBody.toString();
        System.debug('Twilio Webhook Body: ' + body);
        
        Map<String, String> params = parseBody(body);
        
        String fromNumber = params.get('From');
        String messageBody = params.get('Body');
        String mediaUrl = params.get('MediaUrl0');
        String numMedia = params.get('NumMedia');
        
        System.debug('From: ' + fromNumber);
        System.debug('Message: ' + messageBody);
        System.debug('Media URL: ' + mediaUrl);
        
        if(numMedia != null && Integer.valueOf(numMedia) > 0) {
            TwilioFileHandler.handleFileUpload(fromNumber, mediaUrl);
        }
        
        res.statusCode = 200;
        res.responseBody = Blob.valueOf('<Response></Response>');
        res.addHeader('Content-Type', 'text/xml');
    }
    
    private static Map<String, String> parseBody(String body) {
        Map<String, String> params = new Map<String, String>();
        if(String.isBlank(body)) return params;
        
        for(String pair : body.split('&')) {
            List<String> kv = pair.split('=');
            if(kv.size() == 2) {
                params.put(
                    EncodingUtil.urlDecode(kv[0], 'UTF-8'),
                    EncodingUtil.urlDecode(kv[1], 'UTF-8')
                );
            }
        }
        return params;
    }
}
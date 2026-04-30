public class TwilioFileHandler {
    
    @future(callout=true)
    public static void handleFileUpload(String fromNumber, String mediaUrl) {
        try {
            // Step 1: Find Messaging Session by phone number
            String cleanNumber = fromNumber.replace('whatsapp:+', '').replace('whatsapp:', '');
            
            // Step 2: Find Warranty Claim by phone number
            List<Warranty_Claim_Intake__c> claims = [
                SELECT Id, Name, Messaging_Session_Id__c 
                FROM Warranty_Claim_Intake__c 
                WHERE Customer_Phone__c LIKE :('%' + cleanNumber)
                ORDER BY CreatedDate DESC 
                LIMIT 1
            ];
            
            if(claims.isEmpty()) {
                System.debug('No Warranty Claim found for number: ' + cleanNumber);
                return;
            }
            
            Warranty_Claim_Intake__c claim = claims[0];
            System.debug('Found Claim: ' + claim.Name);
            
            // Step 3: Download file from Twilio
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Twilio' + mediaUrl.substringAfter('api.twilio.com'));
            req.setMethod('GET');
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if(res.getStatusCode() == 200) {
                // Step 4: Create ContentVersion (file in Salesforce)
                ContentVersion cv = new ContentVersion();
                cv.Title = 'WhatsApp_Attachment_' + DateTime.now().format('yyyyMMdd_HHmmss');
                cv.PathOnClient = 'WhatsApp_Attachment.jpg';
                cv.VersionData = res.getBodyAsBlob();
                cv.FirstPublishLocationId = claim.Id;
                insert cv;
                
                System.debug('File attached to claim: ' + claim.Name);
            } else {
                System.debug('Failed to download file. Status: ' + res.getStatusCode());
            }
            
        } catch(Exception e) {
            System.debug('Error in handleFileUpload: ' + e.getMessage());
        }
    }
}
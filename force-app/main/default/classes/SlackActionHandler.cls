@RestResource(urlMapping='/slack/actions')
global without sharing class SlackActionHandler {

    @HttpPost
    global static void handleAction() {

        RestResponse res = RestContext.response;

        try {
            RestRequest req = RestContext.request;

            // ✅ Get payload correctly
            String payloadJson;

            if(req.params != null && req.params.containsKey('payload')) {
                payloadJson = req.params.get('payload');
            } else {
                payloadJson = req.requestBody.toString();
            }

            System.debug('Payload JSON: ' + payloadJson);

            if(String.isBlank(payloadJson)){
                respond(res, 'No payload received ❌');
                return;
            }

            Map<String, Object> payload =
                (Map<String, Object>) JSON.deserializeUntyped(payloadJson);

            List<Object> actions = (List<Object>) payload.get('actions');

            if(actions == null || actions.isEmpty()){
                respond(res, 'No actions found ❌');
                return;
            }

            Map<String, Object> actionObj = (Map<String, Object>) actions[0];
            String value = (String) actionObj.get('value');

            System.debug('Button value: ' + value);

            List<String> parts = value.split('\\|');

            if(parts.size() < 2){
                respond(res, 'Invalid button data ❌');
                return;
            }

            String recordId = parts[0];
            String action = parts[1];

            // 🔹 Get response_url (for updating Slack message)
            String responseUrl = (String) payload.get('response_url');

            // 🔹 Fetch record
            Warranty_Claim_Intake__c claim = [
                SELECT Id, Name, Status__c
                FROM Warranty_Claim_Intake__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            // 🚫 Prevent multiple clicks
            if(claim.Status__c == 'Approved' || claim.Status__c == 'Rejected'){

                String alreadyMsg = '⚠️ Claim ' + claim.Name + ' is already ' + claim.Status__c;

                sendSlackUpdate(responseUrl, alreadyMsg);
                respond(res, alreadyMsg);
                return;
            }

            // 🔹 Update status
            if(action == 'APPROVE'){
                claim.Status__c = 'Approved';
            } 
            else if(action == 'REJECT'){
                claim.Status__c = 'Rejected';
            }

            update claim;

            System.debug('✅ Record updated');

            // 🔥 Final message (buttons removed)
            String finalMessage =
                '✅ Claim ' + claim.Name + ' has been *' + claim.Status__c + '*';

            sendSlackUpdate(responseUrl, finalMessage);

            // 🔹 Immediate response to Slack
            respond(res, 'Action completed');

        } catch(Exception e) {

            System.debug('ERROR: ' + e.getMessage());

            respond(res, 'Error processing request ❌');
        }
    }

    // 🔹 Update Slack message (remove buttons)
    private static void sendSlackUpdate(String responseUrl, String message){

        if(String.isBlank(responseUrl)) return;

        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint(responseUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        String body = '{"replace_original":true,"text":"' + message + '"}';

        req.setBody(body);

        try {
            http.send(req);
        } catch(Exception e){
            System.debug('Slack update failed: ' + e.getMessage());
        }
    }

    // 🔹 Standard Slack response
    private static void respond(RestResponse res, String message){
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(
            '{"response_type":"ephemeral","text":"' + message + '"}'
        );
    }
}
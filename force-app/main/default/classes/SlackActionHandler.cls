@RestResource(urlMapping='/slack/actions')
global without sharing class SlackActionHandler {

    @HttpPost
    global static void handleAction() {

        RestResponse res = RestContext.response;

        try {
            RestRequest req = RestContext.request;

            String payloadJson;

            if(req.params != null && req.params.containsKey('payload')) {
                payloadJson = req.params.get('payload');
            } else {
                payloadJson = req.requestBody.toString();
            }

            System.debug('Payload JSON: ' + payloadJson);

            if(String.isBlank(payloadJson)){
                res.statusCode = 200;
                return;
            }

            Map<String, Object> payload =
                (Map<String, Object>) JSON.deserializeUntyped(payloadJson);

            List<Object> actions = (List<Object>) payload.get('actions');
            Map<String, Object> actionObj = (Map<String, Object>) actions[0];

            String value = (String) actionObj.get('value');

            // 🔹 Extract recordId + action
            List<String> parts = value.split('\\|');

            String recordId = parts[0];
            String action = parts[1];

            // 🔹 Get response_url
            String responseUrl = (String) payload.get('response_url');

            Warranty_Claim_Intake__c claim = [
                SELECT Id, Name, Status__c
                FROM Warranty_Claim_Intake__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            // 🔴 Prevent multiple clicks
            if(claim.Status__c == 'Approved' || claim.Status__c == 'Rejected'){

                sendSlackUpdate(responseUrl,
                    '⚠️ Claim ' + claim.Name + ' is already ' + claim.Status__c);

                respond(res, 'Already processed');
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

            // 🔥 Update Slack message (REMOVE BUTTONS)
            String finalMessage =
                '✅ Claim ' + claim.Name + ' has been *' + claim.Status__c + '*';

            sendSlackUpdate(responseUrl, finalMessage);

            // 🔹 Immediate response
            respond(res, 'Action completed');

        } catch(Exception e) {

            System.debug('ERROR: ' + e.getMessage());

            respond(res, 'Error occurred');
        }
    }

    // 🔹 Method to update Slack message
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

    private static void respond(RestResponse res, String msg){
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(
            '{"response_type":"ephemeral","text":"' + msg + '"}'
        );
    }
}
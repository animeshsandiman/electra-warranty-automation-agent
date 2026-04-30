@RestResource(urlMapping='/webhook')
global with sharing class WhatsAppWebhook {

    @HttpGet
    global static void verifyWebhook() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String mode = req.params.get('hub.mode');
        String token = req.params.get('hub.verify_token');
        String challenge = req.params.get('hub.challenge');

        if (mode == 'subscribe' && token == 'myverify123') {
            res.responseBody = Blob.valueOf(challenge);
        }
    }

    @HttpPost
    global static void handleWebhook() {

        String body = RestContext.request.requestBody.toString();
        System.debug('Incoming Payload: ' + body);

        try {
            Map<String, Object> data =
                (Map<String, Object>) JSON.deserializeUntyped(body);

            Map<String, Object> entry =
                (Map<String, Object>) ((List<Object>) data.get('entry'))[0];

            Map<String, Object> changes =
                (Map<String, Object>) ((List<Object>) entry.get('changes'))[0];

            Map<String, Object> value =
                (Map<String, Object>) changes.get('value');

            List<Object> messages = (List<Object>) value.get('messages');

            if (messages != null && !messages.isEmpty()) {

                Map<String, Object> message =
                    (Map<String, Object>) messages[0];

                // Get phone number
                String fromNumber = (String) message.get('from');
                System.debug('From Number: ' + fromNumber);

                String type = (String) message.get('type');

                String mediaId;

                if (type == 'document') {
                    Map<String, Object> doc =
                        (Map<String, Object>) message.get('document');
                    mediaId = (String) doc.get('id');
                }

                if (type == 'image') {
                    Map<String, Object> img =
                        (Map<String, Object>) message.get('image');
                    mediaId = (String) img.get('id');
                }

                // Call service only if media exists
                if (mediaId != null) {
                    WhatsAppService.processMedia(mediaId, fromNumber);
                }
            }

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}
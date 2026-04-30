@RestResource(urlMapping='/WhatsAppWebhook/*')
global without sharing class TwilioWhatsAppWebhook {

    @HttpPost
    global static void receiveMessage() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String messageSid = req.params.get('MessageSid');
        String fromNumber = req.params.get('From');
        String toNumber   = req.params.get('To');
        String body       = req.params.get('Body');
        String numMedia   = req.params.get('NumMedia');

        System.debug('Twilio MessageSid: ' + messageSid);
        System.debug('From: ' + fromNumber);
        System.debug('To: ' + toNumber);
        System.debug('Body: ' + body);
        System.debug('NumMedia: ' + numMedia);

        res.statusCode = 200;
        res.responseBody = Blob.valueOf('OK');
    }
}
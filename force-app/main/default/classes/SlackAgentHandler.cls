@RestResource(urlMapping='/slack/agent')
global with sharing class SlackAgentHandler {

    @HttpPost
    global static void handleRequest() {

        RestResponse res = RestContext.response;

        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(
            '{"response_type":"in_channel","text":"HELLO FROM SALESFORCE"}'
        );
    }
}
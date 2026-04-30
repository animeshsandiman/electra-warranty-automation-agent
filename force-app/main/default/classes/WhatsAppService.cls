public class WhatsAppService {

    // Get Media URL
    public static String getMediaUrl(String mediaId) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://graph.facebook.com/v19.0/' + mediaId);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer YOUR_ACCESS_TOKEN');

        Http http = new Http();
        HttpResponse res = http.send(req);

        Map<String, Object> result =
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        return (String) result.get('url');
    }

    // Download File
    public static Blob downloadFile(String url) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer YOUR_ACCESS_TOKEN');

        Http http = new Http();
        HttpResponse res = http.send(req);

        return res.getBodyAsBlob();
    }

    //  Save File to Correct Record
    public static void saveFile(Blob fileBlob, String fromNumber) {

        //Find latest record using phone number
        Warranty_Claim_Intake__c rec = [
            SELECT Id
            FROM Warranty_Claim_Intake__c
            WHERE Customer_Phone__c = :fromNumber
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        // Create File
        ContentVersion cv = new ContentVersion();
        cv.Title = 'WhatsApp File';
        cv.PathOnClient = 'file.pdf';
        cv.VersionData = fileBlob;

        insert cv;

        // Get ContentDocumentId
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        // Link file to correct record
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = cv.ContentDocumentId;
        link.LinkedEntityId = rec.Id;
        link.ShareType = 'V';

        insert link;
    }

    // COMBINE METHOD
    public static void processMedia(String mediaId, String fromNumber) {

        String url = getMediaUrl(mediaId);
        Blob fileBlob = downloadFile(url);
        saveFile(fileBlob, fromNumber);
    }
}
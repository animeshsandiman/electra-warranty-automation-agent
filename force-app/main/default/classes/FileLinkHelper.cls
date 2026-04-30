public class FileLinkHelper {

    @InvocableMethod(label='Link File to Record')
    public static void linkFile(List<Request> requests) {

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        for(Request r : requests){
            if(r.contentDocumentId != null && r.recordId != null){
                ContentDocumentLink link = new ContentDocumentLink();
                link.ContentDocumentId = r.contentDocumentId;
                link.LinkedEntityId = r.recordId;
                link.ShareType = 'V';
                links.add(link);
            }
        }

        if(!links.isEmpty()){
            insert links;
        }
    }

    public class Request {
        @InvocableVariable(required=true)
        public Id contentDocumentId;

        @InvocableVariable(required=true)
        public Id recordId;
    }
}
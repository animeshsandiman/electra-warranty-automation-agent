public class SlackNotifier {

    @InvocableMethod(label='Send Slack Approval Message')
    public static void sendMessage(List<Id> recordIds) {

        for(Id recId : recordIds){
            System.enqueueJob(new SlackQueueable(recId));
        }
    }
}
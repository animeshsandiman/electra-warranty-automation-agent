public class SlackFlowAction {
    
    @InvocableMethod(label='Send Slack Message')
    public static void sendMessage(List<String> messages) {
        

        for(String msg : messages){
            System.enqueueJob(new SlackQueueable(msg));
        }
    }
}
public class SlackFlowRunner implements Queueable {

    String claimNumber;

    public SlackFlowRunner(String claimNumber){
        this.claimNumber = claimNumber;
    }

    public void execute(QueueableContext context){

        try {
            Map<String, Object> inputs = new Map<String, Object>{
                'ClaimNumber' => claimNumber
            };

            Flow.Interview.Automatic_Slack_Bot flow =
                new Flow.Interview.Automatic_Slack_Bot(inputs);

            flow.start();

            String result = (String) flow.getVariableValue('resultStatus');

            System.debug('FINAL RESULT: ' + result);

            // 👉 Optional: Send result back to Slack using webhook (next step if you want)

        } catch (Exception e) {
            System.debug('FLOW ERROR: ' + e.getMessage());
        }
    }
}
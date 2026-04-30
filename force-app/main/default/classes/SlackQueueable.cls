public class SlackQueueable implements Queueable, Database.AllowsCallouts {

    private Id recId;

    public SlackQueueable(Id recordId){
        this.recId = recordId;
    }

    public void execute(QueueableContext context){

        // Fetch record
        Warranty_Claim_Intake__c claim = [
            SELECT Id, Name
            FROM Warranty_Claim_Intake__c
            WHERE Id = :recId
            LIMIT 1
        ];

        // Build Slack Blocks
        List<Object> blocks = new List<Object>();

        // ✅ Clean header (replaces full section block)
        blocks.add(new Map<String, Object>{
            'type' => 'section',
            'text' => new Map<String, Object>{
                'type' => 'mrkdwn',
                'text' => '*Take Action On Warranty Claim: ' + claim.Name + '*'
            }
        });

        // ✅ Buttons block
        blocks.add(new Map<String, Object>{
            'type' => 'actions',
            'elements' => new List<Object>{
                new Map<String, Object>{
                    'type' => 'button',
                    'text' => new Map<String, Object>{
                        'type' => 'plain_text',
                        'text' => 'Approve'
                    },
                    'style' => 'primary',
                    'value' => claim.Id + '|APPROVE',
                    'action_id' => 'approve'
                },
                new Map<String, Object>{
                    'type' => 'button',
                    'text' => new Map<String, Object>{
                        'type' => 'plain_text',
                        'text' => 'Reject'
                    },
                    'style' => 'danger',
                    'value' => claim.Id + '|REJECT',
                    'action_id' => 'reject'
                }
            }
        });

        // Final payload
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('channel', 'C0ASMAEGFC0'); // your channel ID
        payload.put('text', 'Warranty Claim Action'); // fallback text
        payload.put('blocks', blocks);

        String body = JSON.serialize(payload);

        // Call Slack API
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Slack_API/api/chat.postMessage');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('Slack Response: ' + res.getStatus());
        System.debug('Slack Body: ' + res.getBody());
    }
}
#!/bin/bash
# Create EventBridge rule to trigger Lambda when EC2 stops
REGION="us-east-1"
PRIMARY_INSTANCE_ID="i-xxxxxxxxxxxxxxx"
LAMBDA_ARN="arn:aws:lambda:us-east-1:111122223333:function:start-backup-instance"

aws events put-rule \
  --name "EC2StopTriggerRule" \
  --event-pattern "{\"source\": [\"aws.ec2\"], \"detail-type\": [\"EC2 Instance State-change Notification\"], \"detail\": {\"state\": [\"stopped\", \"terminated\"], \"instance-id\": [\"$PRIMARY_INSTANCE_ID\"]}}" \
  --state ENABLED \
  --region $REGION

aws events put-targets \
  --rule "EC2StopTriggerRule" \
  --targets "Id"="1","Arn"="$LAMBDA_ARN" \
  --region $REGION

aws lambda add-permission \
  --function-name "start-backup-instance" \
  --statement-id AllowEventBridgeInvoke \
  --action lambda:InvokeFunction \
  --principal events.amazonaws.com \
  --source-arn "arn:aws:events:$REGION:111122223333:rule/EC2StopTriggerRule"

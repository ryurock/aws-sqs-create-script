#!/bin/env/bash

SQS_QUEUE_NAME=$1
echo "Try Create SQS queue name: ${SQS_QUEUE_NAME}"

QUEUE_NAME_EXISTS=$(aws sqs list-queues --queue-name-prefix ${SQS_QUEUE_NAME})

if [ ${#QUEUE_NAME_EXISTS} -gt 0 ]; then
    echo "InValid Que name. not uniq Que name"
    exit 1
fi

aws sqs create-queue --queue-name ${SQS_QUEUE_NAME}
echo "Created SQS QUEUE name: ${SQS_QUEUE_NAME}"
aws sqs list-queues --queue-name-prefix ${SQS_QUEUE_NAME}
# SQS VisibilityTimeout
SQS_VTOUT=60

echo "Modified SQS queue-attributes VisibilityTimeout: ${SQS_VTOUT}"
SQS_QUEUE_URL=$( \
        aws sqs get-queue-url \
          --queue-name ${SQS_QUEUE_NAME} \
          --output text \
)
aws sqs set-queue-attributes --queue-url ${SQS_QUEUE_URL} --attributes VisibilityTimeout=${SQS_VTOUT}

# policyの設定ArnLikeの部分を任意のbucketに設定する
SQS_POLICY='{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Principal": { "AWS": "*" },
      "Action":"sqs:SendMessage",
      "Resource":"SQS-queue-ARN",
      "Condition":{
        "ArnLike":{
          "aws:SourceArn": "arn:aws:s3:*:*:fuga"
        }
      }
    }
  ]
}'
SQS_POLICY_ESCAPED=$(echo $SQS_POLICY | perl -pe 's/"/\\"/g')
SQS_POLICY_ATTRIBUTES='{"Policy":"'$SQS_POLICY_ESCAPED'"}'
# policyを設定する
aws sqs set-queue-attributes \
  --queue-url ${SQS_QUEUE_URL} \
  --attributes "$SQS_POLICY_ATTRIBUTES"

echo "Setting SQS QUEUE: ${SQS_QUEUE_NAME}"
aws sqs get-queue-attributes \
        --queue-url ${SQS_QUEUE_URL} \
        --attribute-names \
          Policy \
          VisibilityTimeout \
          MaximumMessageSize \
          MessageRetentionPeriod \
          ApproximateNumberOfMessages \
          ApproximateNumberOfMessagesNotVisible \
          CreatedTimestamp \
          LastModifiedTimestamp \
          QueueArn \
          ApproximateNumberOfMessagesDelayed \
          DelaySeconds \
          ReceiveMessageWaitTimeSeconds \
          RedrivePolicy

echo "SQS Setting Finish URL: ${SQS_QUEUE_URL}"

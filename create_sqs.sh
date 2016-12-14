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

#!/bin/sh

# ./create_billing_alarms.sh <profile> <sns-topic-arn> <name-prefix> <account-id> <threshold-start> <threshold-step> <threshold-end>
# 
# example)
# ./create_billing_alarms.sh myprofile "arn:aws:sns:us-east-1:123456789012" myproduct 123456789012 100 100 2000
#

region="us-east-1"

profile=$1
topic=$2
product=$3
account=$4
start=$5
step=$6
end=$7

for amount in $(seq $start $step $end);
do
    aws --profile=$profile \
        --region=$region cloudwatch put-metric-alarm \
        --alarm-name "[$product] BillingAlarm over \$$amount" \
        --metric-name "EstimatedCharges" \
        --namespace "AWS/Billing" \
        --statistic "Maximum" \
        --period "21600" \
        --evaluation-periods "1" \
        --threshold "$amount" \
        --comparison-operator "GreaterThanThreshold" \
        --dimensions Name=Currency,Value=USD Name=LinkedAccount,Value=$account \
        --actions-enabled \
        --alarm-actions $topic && \
    echo "'[$product] BillingAlarm over \$$amount' created." &
    pids[$!]=$!
done

wait ${pids[@]}
echo "All alarms has been created."

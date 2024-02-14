#!/bin/bash

#Use this script to extract key data from STS when using an AWS profile - you can then sign requests using './callendpoint.sh'

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
tempobj=$(aws sts get-session-token)
export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' <<< $tempobj)
export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' <<< $tempobj)
export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' <<< $tempobj)
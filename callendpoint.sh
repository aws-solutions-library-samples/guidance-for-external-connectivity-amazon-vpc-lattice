#!/bin/bash

#Use this script to make a signed request to your endpoint using the inbuilt sigv4 mechanism in curl.

curl -4 https://hello.palmer-solutions.co.uk \
    --aws-sigv4 "aws:amz:eu-west-1:vpc-lattice-svcs" \
    --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" \
    --header "x-amz-security-token:$AWS_SESSION_TOKEN" \
    --header "x-amz-content-sha256:UNSIGNED-PAYLOAD"
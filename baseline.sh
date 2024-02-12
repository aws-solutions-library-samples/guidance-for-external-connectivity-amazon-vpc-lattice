#!/bin/bash

# 1-liner for deployment of baseline (derived from pipeline-stack.yaml)
aws cloudformation create-stack --template-body file://pipeline-stack.yml --stack-name vpclattice-ingress --capabilities CAPABILITY_IAM
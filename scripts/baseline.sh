#!/bin/bash

# 1-liner for deployment of baseline (derived from pipeline-stack.yaml)
aws cloudformation deploy --template-file ./guidance-stack.yml --stack-name guidance-vpclattice-pipeline --parameter-overrides VPCLatticeServiceNetwork=$VPCLATTICE_SERVICE_NETWORK --capabilities CAPABILITY_IAM
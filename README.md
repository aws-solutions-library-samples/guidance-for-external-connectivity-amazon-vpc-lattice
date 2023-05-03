# Ingress Pattern for Amazon VPC Lattice

## Description

This code bundle builds a [Serverless](https://aws.amazon.com/serverless/) ingress solution, enabling [Amazon VPC Lattice](https://aws.amazon.com/vpc/lattice/) Services to be reached by consumers that reside outside of the Amazon Virtual Private Cloud ([VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)) both from trusted (on-premise) and non-trusted (external) locations.

## Solution Overview

**This solution is deployed in two parts, the first is the Base solution** 

The base solution copies the code in this repo into your own AWS account and enables you to iterate on it - your changes, as you make them will be saved to your own git compliant repo from which you can orchestrate deployment. The stack template sets up an [Amazon Virtual Private Cloud](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) across three [Availability Zones](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) with both public and private subnets across all three as well as supporting infrastructure such as [NAT Gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html), [Route Tables](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html) and an [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html). The stack also creates the infrastructure that is needed to iterate on your code releases and deploys an [AWS Code Commit](https://aws.amazon.com/codecommit/)repo for holding the code, an [Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/) for storing container images, an [AWS CodeBuild](https://aws.amazon.com/codebuild/) environment for building containers that run an open-source version of [NGINX](https://www.nginx.com/) and an [AWS CodePipeline](https://aws.amazon.com/codepipeline/) for the orchestration of the solution build and delivery. Once deployed, your pipeline is ready for release.

**The following depicts the base solution:**

![image](/img/nginx-docker-Base.drawio.png)

**The second part of this solution deploys the ingress compute components**

The pipeline deploys the following [template](/cloudformation/ecs/cluster.yaml) into your AWS account using CloudFormation. The stack template sets up '**External**' access by deploying an internet-facing [Amazon Network Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html) that is deployed into the three public subnets and across the three Availability Zones. The stack template also sets up internal access (hybrid) by using an internal load balancer that can only be reached from within the Amazon Virtual Private Cloud or via hybrid connections such as [AWS Virtual Private Network](https://docs.aws.amazon.com/vpc/latest/userguide/vpn-connections.html) or [AWS Direct Connect](https://docs.aws.amazon.com/directconnect/latest/UserGuide/Welcome.html) and four [Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-target-groups.html) that are used to pass traffic to back-end compute instances. The stack template sets up an [Elastic Container Service Cluster](https://aws.amazon.com/ecs/) an [ECS Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) and an [ECS Service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) that uses [Amazon Fargate](https://aws.amazon.com/fargate/) as the capacity provider. As Amazon Fargate tasks are deployed, they are mapped to the external and internal load balancer target groups which are bound to two 'tcp' listeners configured for ports 80 and 443. ECS Tasks therefore service both internal and external traffic.

**The following depicts the complete solution:**

![image](/img/nginx-docker-ECS-cluster.drawio.png)

## Deployment

Deployment of this solution is straight forward, you must deploy the ingress [stack template](/pipeline-stack.yml) in any [AWS Region](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) where you are publishing [Amazon VPC Lattice Services](https://docs.aws.amazon.com/vpc-lattice/latest/ug/services.html). More succinctly, you must deploy this stack as many times as you have distinct Amazon Lattice VPC Service Networks in a region, since there is a 1:1 mapping between Service Networks and Amazon VPCs.
  
## Performance

A level of performance testing was run against this solution. The specifics of the testing were as follows:

    -   Region tested us-west-2
    -   The Amazon VPC Lattice Service Published was [AWS LAMBDA](https://aws.amazon.com/lambda/)
        -   This was a simple LAMBDA, that had concurrency elevated to 3000 (from 1000 base)
    -   External access via a three-zone AWS Network Load Balancer using DNS for round-robin on requests
    -   AWS NLB was not configured for X-zone load balancing (in tests, this performed less well)
    -   Three zonal AWS Fargate Tasks bound to the Network Load Balancer
        -   Each task had 2048 CPU units and 4096MB RAM

The testing harness used came from an AWS quick start solution that can be found [here](https://aws.amazon.com/solutions/implementations/distributed-load-testing-on-aws/) and additionally, the template can be found in this repo, [here](/load-test/distributed-load-testing-on-aws.template).

The following results show the harness performance, NLB performance, VPC Lattice performance and LAMBDA performance given 5000 remote users, generating ~3000 requests per second, with sustained access for 20 mins and a ramp-up time of 5 minutes.

**Harness Performance**

![image](/img/perf-testing-harness.png)

![image](/img/perf-testing-percentiles.png)

**ECS Performance**

![image](/img/perf-testing-ecs.png)

**LAMBDA Performance**

![image](/img/perf-testing-lambda.png)

**VPC Lattice Performance**

![image](/img/perf-testing-lattice.png)

## Clean-up

Clean-up of this solution is straight-forward. First, start by removing the stack that was created by the CodPipeline - this can be identified in the CloudFormation console with the name **$AWS::StackName-AWS::AccountId-ecs**. Once this has been removed, you can remove the parent stack that built the base stack. 

***NOTE*** The ECR repo and the S3 bucket will remain and should be removed manually

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.


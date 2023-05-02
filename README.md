# Ingress Pattern for Amazon VPC Lattice

## Description

This code bundle builds a [Serverless](https://aws.amazon.com/serverless/) ingress solution, ebaling [Amazon VPC Lattice](https://aws.amazon.com/vpc/lattice/) Services to be reached by consumers that reside outside of the Amazon Virtual Private Cloud ([VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)) both from trusted (on-premise) and non-trusted (external) locations.

**The following depicts the base solution:**

![image](/img/nginx-docker-Base.drawio.png)

**This solution is deployed in two parts, the first is the Base solution** 

The base solution copies the code in this repo into your own AWS account and enables you to iterate on it - your changes, as you make them will be saved to your own git compliant repo from which you can orchestrate deployment. The stack template sets up an [Amazon Virtual Private Cloud](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) across three [Availability Zones](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) with both public and private subnets across all three as well as supporting infrastructure such as [NAT Gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html), [Route Tables](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html) and an [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html). The stack also creates the infrastructure that is needed to iterate on your code releases and deploys an [AWS Code Commit](https://aws.amazon.com/codecommit/)repo for holding the code, an [Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/) for storing container images, an [AWS CodeBuild](https://aws.amazon.com/codebuild/) environment for building containers that run an open-source version of [NGINX](https://www.nginx.com/) and an [AWS CodePipeline](https://aws.amazon.com/codepipeline/) for the orchestration of the solution build and delivery. Once deployed, your pipeline is ready for release.

**The second part of this solution deploys the ingress compute components**

The pipeline deploys the following [template](/cloudformation/ecs/cluster.yaml) into your AWS account using CloudFormation. The stack template sets up '**External**' access by deploying an internet-facing [Amazon Network Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html) that is deployed into the three public subnets and across the three Availability Zones. The stack template also sets up internal access (hybrid) by using an internal load balancer that can only be reached from within the Amazon Virtual Private Cloud or via hybrid connections such as [AWS Virtual Private Network](https://docs.aws.amazon.com/vpc/latest/userguide/vpn-connections.html) or [AWS Direct Connect](https://docs.aws.amazon.com/directconnect/latest/UserGuide/Welcome.html) and four [Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-target-groups.html) that are used to pass traffic to back-end compute instances. The stack template sets up an [Elastic Container Service Cluster](https://aws.amazon.com/ecs/) an [ECS Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) and an [ECS Service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) that uses [Amazon Fargate](https://aws.amazon.com/fargate/) as the capacity provider. As Amazon Fargate tasks are deployed, they are mapped to the external and internal load balancer target groups which are bound to two 'tcp' listeners configured for ports 80 and 443. ECS Tasks therefore service both internal and external traffic.

**The following depicts the complete solution:**

![image](/img/nginx-docker-ECS-cluster.drawio.png)

## Deployment

Deployment of this solution is straight forward, you must deploy the ingress [stack template](/pipeline-stack.yml) in any [AWS Region](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) where you are publishing [Amazon VPC Lattice Services](https://docs.aws.amazon.com/vpc-lattice/latest/ug/services.html). More succinctly, you must deploy this stack as many times you have distinct Amazon Lattice VPC Service Networks in a region, since there is a 1:1 mapping between Service Networks and Amazon VPCs.

**When the stack deploys it does the following:**

1. Pulls the code from this [repo](https://github.com/aws-samples/ingress-patterns-with-amazon-vpc-lattice)
2. Creates an Amazon S3 bucket for storing pipeline artefacts and committed code (for archival)
3. Sets up an [Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/) for storing container images
4. Creates an ingress VPC and supporting constructs (subnets,gateways,routes and security groups)
5. Creates a [Code Pipeline](https://aws.amazon.com/codepipeline/) for managing the solution using CI/CD principles which does the following (**once released**):
    -   Pulls the public Amazon Linux 2 container image (ARM64)
    -   Builds a container image and stores this in ECR
    -   Builds an [Elastic Container Service Cluster](https://aws.amazon.com/ecs/) an [ECS Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) and [ECS Service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) that uses [Amazon Fargate (Fargate)](https://aws.amazon.com/fargate/) as the capacity provider
    -   Builds internet-facing and internal Network Load Balancers for servicing the fleet of Amazon Fargate Tasks  
## Performance

{todo} - needs benchmarking configuration and image snapshots

## Clean-up

{todo} - need removal guidance for the stack

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.


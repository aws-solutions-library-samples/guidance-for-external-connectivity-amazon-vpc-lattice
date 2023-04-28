# Ingress Patterns with Amazon VPC Lattice

## Description

This code bundle, once deployed will enable [Amazon VPC Lattice](https://aws.amazon.com/vpc/lattice/) Services to be reached by consumers that reside outside of the Amazon Virtual Private Cloud ([VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)), from trusted (on-premise) and non-trusted (external) locations.

{todo} - needs solution overview diagram

## Deployment

Deployment of this solution is straight forward, you must deploy the ingress [stack](/pipeline-stack.yml) in any [AWS Region](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) where you are publishing [Amazon VPC Lattice Services](https://docs.aws.amazon.com/vpc-lattice/latest/ug/services.html). When the stack deploys it does the following:

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


# Amazon VPC Lattice - Provider Example

The AWS CloudFormation template in this folder provides you an example you can use to validate the Ingress pattern discussed in this repository, with an example VPC Lattice Service Network and Service you can deploy. The template deploys the following:

* VPC Lattice resources: Service Network, Service, 2 Target Groups (Instance and Lambda Type), HTTPS Listener, and Rules to forward traffic to both target groups.
* Two services: AWS Lambda function and Auto Scaling group. Both services only provide a simple *hello* message.
* Optionally, you can also build the following:
  * VPC Lattice VPC Assocation, if you provide the Ingress VPC ID created by the solution pipeline.
  * Route 53 CNAME records, if ypu provide a Hosted Zone ID and the Ingress NLB domain name.

![image](../../img/example-diagram.png)

## Inputs

| Name | Description | Required |
|------|-------------|:--------:|
| CustomDomainName | Custom Domain Name for the VPC Lattice Service. | yes |
| CertificateARN | ARN of the AWS Certificate Manager certificate to associate to the VPC Lattice Service. | yes |
| ConsumerHostedZoneID | Public or Private Hosted Zone ID for the consumer application DNS resolution (CNAME record). | no |
| IngressHostedZoneId | Private Hosted Zone ID for the proxy solution DNS resoltuion (CNAME record). | no |
| IngressNLBDomainName | NLB domain name - created in Ingress VPC. | no |
| IngressVpcId | Ingress VPC ID (for Service Network VPC Association). | no |

## Deployment and Clean-up

* Deployment of this repository is straight forward, you must deploy the stack template in any AWS Region where you want to test ingress solution - that way you can associate that Ingress VPC to the Service Network created.
* Clean-up of this solution is straight-forward, you must remove the stack created to build the resources described in this README.

## DNS resolution configuration

To have a complete example deployed to test the ingress connectivity to the VPC Lattice services, you need to make sure DNS resolution is properly configured. The repository ask for two [Route 53 Hosted Zones](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html): 

* `ConsumerHostedZoneID`: this is the Hosted Zone that is going to be consumed by the consumer application - not located in the VPC associated to Lattice. Depending the ingress pattern, this Hosted Zone need to be Public or Private.
  * If the consumer application need to consume the Lattice Service using the Internet, this Hosted Zone should be Public.
  * If the consumer application is located in on-premises environment, this Hosted Zone should be Private and associated with a VPC where you have [Route 53 Resolver Inbound endpoints](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver.html) or your own custom Hybrid DNS solution.
  * If the consumer application is located in other AWS Region, this Hosted Zone should be Private and associated with the VPC where this application is located.
* `IngressHostedZoneID`: this is a Private Hosted Zone that you need to associate with the Ingress VPC created within this solution.

This repository does not create any Hosted Zone, leaving you the freedom to create them or re-use the ones you already use in your environments.

In addition, the variable `IngressNLBDomainName` should be provided, in order to properly create the CNAME record in the *"Consumer Hosted Zone"*. If the consumer application will use Internet to reach the Lattice Service, you need to provide the domain name of the public NLB created by this solution. Otherwise, you need to provide the domain name of the private NLB created.
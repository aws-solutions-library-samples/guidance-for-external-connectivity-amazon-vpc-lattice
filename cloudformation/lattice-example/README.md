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
| HostedZoneId | Public or Private Hosted Zone ID (to create CNAME record). | no |
| IngressNLBDomainName | NLB domain name - created in Ingress VPC. | no |
| IngressVpcId | Ingress VPC ID (for Service Network VPC Association). | no |

## Deployment and Clean-up

* Deployment of this repository is straight forward, you must deploy the stack template in any AWS Region where you want to test ingress solution - that way you can associate that Ingress VPC to the Service Network created.
* Clean-up of this solution is straight-forward, you must remove the stack created to build the resources described in this README.

## DNS resolution configuration



### Public resolution



### Private resolution
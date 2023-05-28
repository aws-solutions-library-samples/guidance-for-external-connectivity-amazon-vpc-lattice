# Amazon VPC Lattice - Service Network & Service Example (AWS CLOUDFORMATION)

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

* Deployment of this repository is straight forward, you must deploy the stack template in any AWS Region where you want to test ingress solution - that way you can associate that ingress VPC to the Service Network created.
* Clean-up of this solution is straight-forward, you simply remove the stack.
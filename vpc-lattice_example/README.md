# Amazon VPC Lattice - Service Network & Service Example

This folder provides you an example you can use to validate the ingress pattern discussed in this repository, with an example VPC Lattice Service Network and Service you can deploy. You can find the example both [AWS CloudFormation](./cloudformation/) and [Terraform](./terraform/). In both examples the following resources are deployed:

* VPC Lattice resources: Service Network, Service, Target Group (Lambda Type), HTTPS Listener, and default Rule to forward traffic to the Lambda target.
* Optionally, you can also build the following:
  * VPC Lattice VPC Association, if you provide the ingress VPC ID created by the solution pipeline.
  * Route 53 CNAME records, if you provide a Hosted Zone ID and the ingress NLB domain name.

![image](../img/example-diagram.png)

## Deployment and Clean-up

Check in each specific example (CloudFormation or Terraform) the instructions provided to deploy and clean-up the resources.

## DNS resolution configuration

To have a complete example deployed to test the ingress connectivity to the VPC Lattice services, you need to make sure DNS resolution is properly configured. Both examples ask for two [Route 53 Hosted Zones](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html): 

* `ConsumerHostedZoneID` / `consumer_hostedzone_id`: this is the Hosted Zone that is going to be consumed by the consumer application - not located in the VPC associated to Lattice. Depending the ingress pattern, this Hosted Zone need to be Public or Private.
  * If the consumer application need to consume the Lattice Service using the Internet, this Hosted Zone should be Public.
  * If the consumer application is located in on-premises environment, this Hosted Zone should be Private and associated with a VPC where you have [Route 53 Resolver Inbound endpoints](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver.html) or your own custom Hybrid DNS solution.
  * If the consumer application is located in other AWS Region, this Hosted Zone should be Private and associated with the VPC where this application is located.
* `IngressHostedZoneID` / `ingress_hostedzone_id`: this is a Private Hosted Zone that you need to associate with the ingress VPC created within this solution.

This repository does not create any Hosted Zone, leaving you the freedom to create them or re-use the ones you already use in your environments.

In addition, the variable `IngressNLBDomainName` / `ingress_nlb_domainname` should be provided, in order to properly create the CNAME record in the *"Consumer Hosted Zone"*. If the consumer application will use Internet to reach the Lattice Service, you need to provide the domain name of the public NLB created by this solution. Otherwise, you need to provide the domain name of the private NLB created.
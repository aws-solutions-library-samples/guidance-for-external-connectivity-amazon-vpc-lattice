# Amazon VPC Lattice - Service Network & Service Example

This folder provides you an example you can use to validate the ingress pattern discussed in this repository, with an example VPC Lattice Service Network and Service you can deploy. You can find the example both [AWS CloudFormation](./cloudformation/) and [Terraform](./terraform/). In both examples the following resources are deployed:

* VPC Lattice resources: Service Network, Service, Target Group (Lambda Type), HTTPS Listener, and default Rule to forward traffic to the Lambda target.
* Optionally, you can also build the following:
  * VPC Lattice VPC Association, if you provide the ingress VPC ID created by the solution pipeline.
  * Route 53 CNAME records, if you provide a Hosted Zone ID and the ingress NLB domain name.

![image](../img/example-diagram.png)

## Deployment and Clean-up

Check in each specific example (CloudFormation or Terraform) the instructions provided to deploy and clean-up the resources.
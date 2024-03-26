# Guidance for External Connectivity to Amazon VPC Lattice (Examples)

In this folder you have two files that provide the following examples:

* `vpc-lattice_service.yml` builds the VPC Lattice resources needed to test the Guidance: service network, service, and [AWS Lambda](https://aws.amazon.com/pm/lambda) target.
* `dns-resolution.yml` creates and configures the corresponding Route 53 hosted zones to provide end-to-end service consumption using this Guidance.

## Variables

### vpc-lattice_service.yaml

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| CustomDomainName | Custom Domain Name (VPC Lattice service) | `String` | yes |
| CertificateArn | Certificate ARN (for HTTPS connection) | `String` | yes |

### dns-resolution.yaml

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| HostedZoneName | Private Hosted Zone Name (for External Connectivity VPC resolution) | `String` | yes |
| CustomDomainName | Custom Domain Name (VPC Lattice service) | `String` | yes |
| VPCLatticeDomainName | VPC Lattice service generated Domain Name | `String` | yes |
| VpcId | VPC ID (External Connectivity) | `String` | yes |
| NLBExternalDomainName | Network Load Balancer domain name (Public Access) | `String` | no |
| NLBInternalDomainName | Network Load Balancer domain name (Hybrid/Cross-Region Access) | `String` | no |
| PublicHostedZone | Amazon Route 53 Public Hosted Zone ID (Public Access) | `String` | no |
| PrivateHostedZone | Amazon Route 53 Private Hosted Zone ID (Hybrid/Cross-Region Access) | `String` | no |

## Deployment steps

1. First, deploy the `vpc-lattice_service.yaml` template to create the VPC Lattice resources. You will need to provide the following parameters: *CustomDomainName* and *CertificateArn*.

```
aws cloudformation deploy --template-file vpc-lattice_service.yml --stack-name vpclattice-service-example --parameter-overrides CustomDomainName="$CUSTOM_DOMAIN_NAME" CertificateArn="$CERTIFICATE_ARN" --capabilities CAPABILITY_IAM
```

2. Obtain the VPC Lattice service network and VPC Lattice-generated domain name.

```
export VPCLATTICE_SERVICE_NETWORK=$(aws cloudformation describe-stacks --stack-name vpclattice-service-example --query 'Stacks[0].Outputs[?OutputKey == `VPCLatticeServiceNetwork`].OutputValue' --output text)

export VPCLATTICE_DOMAIN_NAME=$(aws cloudformation describe-stacks --stack-name vpclattice-service-example --query 'Stacks[0].Outputs[?OutputKey == `VPCLatticeServiceGeneratedDomainName`].OutputValue' --output text)
```

3. Deploy the Guidance architecture as explained in the root [README](../README.md#deployment-steps)

4. Obtain the VPC ID and NLB domain name (internal and/or external) deployed by the Guidance.

```
export VPC_ID=$(aws cloudformation describe-stacks --stack-name guidance-vpclattice-pipeline-867003233025-ecs --query 'Stacks[0].Outputs[?OutputKey == `VpcId`].OutputValue' --output text)

export NLB_INT_DOMAIN_NAME=$(aws cloudformation describe-stacks --stack-name guidance-vpclattice-pipeline-867003233025-ecs --query 'Stacks[0].Outputs[?OutputKey == `NginxIntNLB`].OutputValue' --output text)

export NLB_EXT_DOMAIN_NAME=$(aws cloudformation describe-stacks --stack-name guidance-vpclattice-pipeline-867003233025-ecs --query 'Stacks[0].Outputs[?OutputKey == `NginxExtNLB`].OutputValue' --output text)
```

5. Now you can deploy the DNS resolution example. You will need to provide the following parameters: *VpcId*, *HostedZoneName*, *CustomDomainName*, *VPCLatticeDomainName*, *PublicHostedZone* (optional), *PrivateHostedZone* (optional), *NLBExtDomainName* (optional), and *NLBIntDomainName* (optional).

```
aws cloudformation deploy --template-file dns-resolution.yml --stack-name vpclattice-dns-example --parameter-overrides HostedZoneName="$HOSTED_ZONE_NAME" CustomDomainName="$CUSTOM_DOMAIN_NAME" VPCLatticeDomainName="$VPCLATTICE_DOMAIN_NAME" NLBExternalDomainName="$NLB_EXT_DOMAIN_NAME" NLBInternalDomainName="$NLB_INT_DOMAIN_NAME" VpcID="$VPC_ID" PublicHostedZone="$PUBLIC_HZ" PublicHostedZone="$PRIVATE_HZ" --capabilities CAPABILITY_IAM
```


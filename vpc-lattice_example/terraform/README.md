<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - Service Network & Service Example (TERRAFORM)

## Code Principles

* Writing DRY (Do No Repeat Yourself) code using a modular design pattern.

## Usage

* Clone the repository.
* Edit the *variables.tf* to:
    * Provide the AWS Region to deploy the environments.
    * Provide the custom domain name and certificate ARN for the Lattice Service.
    * If desired, provide the Hosted Zone IDs and NLB domain name to create the Route 53 records.

## Deployment

* Use `terraform apply` to deploy the resources.
* Use `terraform destroy` to clean-up your environment.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log_group_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.log_group_lattice](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy_attachment.lambdabasic_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.role_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lambda_function.lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_route53_record.consumer_cname_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.ingress_cname_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_vpclattice_access_log_subscription.log_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_auth_policy.service_auth_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_auth_policy) | resource |
| [aws_vpclattice_auth_policy.sn_auth_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_auth_policy) | resource |
| [aws_vpclattice_listener.listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_listener) | resource |
| [aws_vpclattice_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service) | resource |
| [aws_vpclattice_service_network.service_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network) | resource |
| [aws_vpclattice_service_network_service_association.service_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network_service_association) | resource |
| [aws_vpclattice_service_network_vpc_association.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network_vpc_association) | resource |
| [aws_vpclattice_target_group.lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_target_group) | resource |
| [aws_vpclattice_target_group_attachment.lambda_target_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_target_group_attachment) | resource |
| [archive_file.zip_python_code](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to build the resources. | `string` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of the AWS Certificate Manager certificate to associate to the VPC Lattice Service. | `string` | n/a | yes |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | Custom Domain Name for the VPC Lattice Service. | `string` | n/a | yes |
| <a name="input_consumer_hostedzone_id"></a> [consumer\_hostedzone\_id](#input\_consumer\_hostedzone\_id) | (OPTIONAL) Public or Private Hosted Zone ID for the consumer application DNS resolution. | `string` | `""` | no |
| <a name="input_ingress_hostedzone_id"></a> [ingress\_hostedzone\_id](#input\_ingress\_hostedzone\_id) | (OPTIONAL) Private Hosted Zone ID for the proxy solution DNS resolution. | `string` | `""` | no |
| <a name="input_ingress_nlb_domainname"></a> [ingress\_nlb\_domainname](#input\_ingress\_nlb\_domainname) | (OPTIONAL) NLB domain name - created in the ingress VPC. | `string` | `""` | no |
| <a name="input_ingress_vpc_id"></a> [ingress\_vpc\_id](#input\_ingress\_vpc\_id) | (OPTIONAL) Ingress VPC ID - for the Service Network VPC association. | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
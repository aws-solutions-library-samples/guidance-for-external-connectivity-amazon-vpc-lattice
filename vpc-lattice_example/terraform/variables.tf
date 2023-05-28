/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- vpc-lattice_example/terraform/providers.tf ---

variable "aws_region" {
  description = "AWS Region to build the resources."
  type        = string
}

variable "custom_domain_name" {
  description = "Custom Domain Name for the VPC Lattice Service."
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the AWS Certificate Manager certificate to associate to the VPC Lattice Service."
  type        = string
}

variable "consumer_hostedzone_id" {
  description = "(OPTIONAL) Public or Private Hosted Zone ID for the consumer application DNS resolution."
  type        = string
  default     = ""
}

variable "ingress_hostedzone_id" {
  description = "(OPTIONAL) Private Hosted Zone ID for the proxy solution DNS resolution."
  type        = string
  default     = ""
}

variable "ingress_nlb_domainname" {
  description = "(OPTIONAL) NLB domain name - created in the ingress VPC."
  type        = string
  default     = ""
}

variable "ingress_vpc_id" {
  description = "(OPTIONAL) Ingress VPC ID - for the Service Network VPC association."
  type        = string
  default     = ""
}
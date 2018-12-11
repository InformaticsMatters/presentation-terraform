# -----------------------------------------------------------------------------
# Mandatory Parameters (must be defined externally)
# -----------------------------------------------------------------------------
#
# For this demo to work you will need a suitable AWS account
# and AWS API keys and the name of a keypair known to AWS
# in the chosen region.

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_name" {}

# -----------------------------------------------------------------------------
# Default Variables
# -----------------------------------------------------------------------------

variable "region" {
  default = "eu-central-1"
}

variable "resource_tag" {
  default = "demo-2"
}

variable "public_node_count" {
  default = 1
}

variable "private_node_count" {
  default = 1
}

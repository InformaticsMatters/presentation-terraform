# -----------------------------------------------------------------------------
# AWS data objects
# -----------------------------------------------------------------------------

# The list of available zones in the user's region
data "aws_availability_zones" "available" {
  state = "available"
}

# Find a recent Amazon Linux AMI
data "aws_ami" "demo_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

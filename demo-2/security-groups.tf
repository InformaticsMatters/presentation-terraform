# -----------------------------------------------------------------------------
# SSH security group
# -----------------------------------------------------------------------------

resource "aws_security_group" "ssh" {
  name = "${var.resource_tag}-ssh"
  description = "Allow SSH connections from anywhere"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${module.vpc.vpc_id}"

  tags {
    Name = "${var.resource_tag}-ssh"
  }
}

# -----------------------------------------------------------------------------
# Outbound
# -----------------------------------------------------------------------------

resource "aws_security_group" "outbound-general" {
  name = "${var.resource_tag}-outbound"
  description = "Open-up the outbound connections."

  # Any outbound traffic...
  egress  {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${module.vpc.vpc_id}"

  tags {
    Name = "${var.resource_tag}-outbound"
  }
}

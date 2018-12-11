# -----------------------------------------------------------------------------
# Public instance definition
# -----------------------------------------------------------------------------
# Connected to the VPC public subnect
# and assigned a public IP address

resource "aws_instance" "public" {
  ami = "${data.aws_ami.demo_ami.image_id}"
  instance_type = "t2.micro"
  count = "${var.public_node_count}"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}",
                            "${aws_security_group.outbound-general.id}"]

  subnet_id = "${module.vpc.public_subnets[0]}"

  associate_public_ip_address = true

  tags {
    Name = "${var.resource_tag}-public-${format("%02d", count.index + 1)}"
  }
}

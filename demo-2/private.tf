# -----------------------------------------------------------------------------
# Private instance definition
# -----------------------------------------------------------------------------
# Connected to the VPC private subnect

resource "aws_instance" "private" {
  ami = "${data.aws_ami.demo_ami.image_id}"
  instance_type = "t2.micro"
  count = "${var.private_node_count}"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}"]

  subnet_id = "${module.vpc.private_subnets[0]}"

  tags {
    Name = "${var.resource_tag}-private-${format("%02d", count.index + 1)}"
  }
}

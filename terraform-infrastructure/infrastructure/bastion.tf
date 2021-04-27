resource "aws_instance" "bastion" {
  ami = var.bastion_ami_id
  instance_type = "t3.small"
  associate_public_ip_address = true
  subnet_id = module.vpc.subnet_id1
  key_name = var.key_pair

  tags = {
    Name = "bastion-${var.environment}"
  }
}
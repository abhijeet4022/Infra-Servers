resource "aws_instance" "nexus" {
  ami           = data.aws_ami.rhel.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.sg.name]


  tags = {
    Name = "Nexus-Server"
  }

}


resource "aws_route53_record" "A" {
  zone_id = var.zone_id
  name    = "nexus.learntechnology.space"
  type    = "A"
  ttl     = 30
  records = [aws_instance.nexus.private_ip]
}
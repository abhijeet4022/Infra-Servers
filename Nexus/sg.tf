resource "aws_security_group" "sg" {
  name        = "allow_all_ports"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "allow_all_ports"
    project = "roboshop"
  }
}

# Inbound Rule: Allow all TCP traffic from anywhere
resource "aws_vpc_security_group_ingress_rule" "allow_all_inbound" {
  security_group_id = aws_security_group.sg.id
  description       = "Allow-all-inbound-traffic"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "tcp"
  tags = { Name = "allow_all_inbound" }
}

# Outbound Rule: Allow all protocols to anywhere
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.sg.id
  description       = "Allow-all-outbound-traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags = { Name = "allow_all_outbound" }
}

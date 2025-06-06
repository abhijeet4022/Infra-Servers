resource "aws_security_group" "sg" {
  name        = "allow_nexus_ports"
  description = "Allow inbound and outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "allow_nexus_ports"
  }
}

# Inbound Rule: Allow all TCP traffic from anywhere
locals {
  nexus_ports = ["22", "8081"]
}

resource "aws_vpc_security_group_ingress_rule" "allow_nexus_ports" {
  for_each          = toset(local.nexus_ports)
  security_group_id = aws_security_group.sg.id
  description       = "Allow inbound traffic on port ${each.value}"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"

  tags = {
    Name = "allow_port_${each.value}"
  }
}


# Outbound Rule: Allow all protocols to anywhere
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.sg.id
  description       = "Allow-all-outbound-traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags = { Name = "allow_all_outbound" }
}

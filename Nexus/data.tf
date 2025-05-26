# Fetch the latest AMI for RHEL 9 from devops community.
data "aws_ami" "rhel" {
  most_recent = true
  name_regex  = "RHEL-9-DevOps-Practice"
  owners      = ["973714476881"]
}
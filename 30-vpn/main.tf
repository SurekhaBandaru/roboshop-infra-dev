resource "aws_key_pair" "openvpn" {
  key_name   = "openvpn"
  public_key = file("D:\\Surekha\\Devops\\Keys\\openvpn.pub") #windows path use //, load the available pub key from our laptop, for mac use /
}

resource "aws_instance" "vpn" { #we used open vpn ami in aws when creating manually
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.vpn_sg_id]
  subnet_id              = local.public_subnet_ids # we create vpn in public subnet
  #key_name               = "daws-84sKeyz" "daws-84sKey" - this is existing one  
  key_name  = aws_key_pair.openvpn.key_name #         # already we created private key in local using linux ssh-keygen -f DevOpsTraining .... and based on this we created a key in aws manually previously
  user_data = file("openvpn.sh")
  tags = merge(local.common_tags,

    {
      Name = "${var.project}-${var.environment}-vpn"

  })
}


#as vpn's ip address gets changed everytime when restarted/recreated, we can create a route 53 record
resource "aws_route53_record" "vpn" {
  zone_id         = var.route53_zone_id
  name            = "vpn-${var.environment}.${var.route53_zone_name}" #vpn-dev.devopspract.site
  type            = "A"
  ttl             = 1
  records         = [aws_instance.vpn.public_ip]
  allow_overwrite = true

}
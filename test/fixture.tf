variable "common_tags" {
  type = map(string)
  default = {
    owner     = ""
    project   = "terratest-client-vpn"
    terraform = "true"
  }
}

module "aws_client_vpn" {
  source                       = "../"
  client_vpn_cidr              = "192.168.148.0/22"
  common_tags                  = var.common_tags
  name_tag_prefix              = "terratest-client-vpn"
  server_cert_public_key_path  = "./certs/server.crt"
  server_cert_private_key_path = "./certs/server.key"
  server_cert_chain_path       = "./certs/ca.crt"
  client_cert_private_key_path = "./certs/client1.domain.tld.key"
  client_cert_public_key_path  = "./certs/client1.domain.tld.crt"
  client_cert_chain_path       = "./certs/ca.crt"
  associated_subnet_ids        = module.aws_basic_nw.public_subnet_ids
}

output "aws_ec2_client_vpn_endpoint_id" {
  value = module.aws_client_vpn.aws_ec2_client_vpn_endpoint_id
}

module "aws_basic_nw" {
  source               = "github.com/slavrd/terraform-aws-basic-network?ref=0.1.1"
  vpc_cidr_block       = "172.25.0.0/24"
  public_subnet_cidrs  = ["172.25.0.0/26"]
  name_prefix          = "terratest-aws-client-vpn"
  private_subnet_cidrs = []
  common_tags          = var.common_tags
}
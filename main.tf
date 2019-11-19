resource "aws_acm_certificate" "server" {
  count             = var.server_cert_arn == null ? 1 : 0
  private_key       = file(var.server_cert_private_key_path)
  certificate_body  = file(var.server_cert_public_key_path)
  certificate_chain = var.server_cert_chain_path == null ? null : file(var.server_cert_chain_path)
  tags = merge({
    Name = "${var.name_tag_prefix}-client-vpn-server"
    },
  var.common_tags)
}

resource "aws_acm_certificate" "client" {
  count             = var.client_cert_arn == null ? 1 : 0
  private_key       = file(var.client_cert_private_key_path)
  certificate_body  = file(var.client_cert_public_key_path)
  certificate_chain = var.client_cert_chain_path == null ? null : file(var.client_cert_chain_path)
  tags = merge({
    Name = "${var.name_tag_prefix}-client-vpn-client"
    },
  var.common_tags)
}

resource "aws_ec2_client_vpn_endpoint" "vpn_endpoint" {
  description            = ""
  server_certificate_arn = var.server_cert_arn == null ? aws_acm_certificate.server[0].arn : var.server_cert_arn
  client_cidr_block      = var.client_vpn_cidr
  transport_protocol     = var.transport_protocol

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_cert_arn == null ? aws_acm_certificate.client[0].arn : var.client_cert_arn
  }

  connection_log_options {
    enabled = var.logging_enable
  }

  tags = merge({
    Name = "${var.name_tag_prefix}-client-vpn"
    },
  var.common_tags)
}

resource "aws_ec2_client_vpn_network_association" "vpn_endpoint" {
  for_each               = toset(var.associated_subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  subnet_id              = each.value
}

resource "null_resource" "vpn_internet_route" {
  depends_on = [aws_ec2_client_vpn_endpoint.vpn_endpoint]
  provisioner "local-exec" {
    command = "aws ec2 create-client-vpn-route --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.vpn_endpoint.id} --destination-cidr-block 0.0.0.0/0 --target-vpc-subnet-id ${var.associated_subnet_ids[0]}"
  }
}

resource "null_resource" "vpn_authorization" {
  depends_on = [aws_ec2_client_vpn_endpoint.vpn_endpoint]
  provisioner "local-exec" {
    command = "aws ec2 authorize-client-vpn-ingress --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.vpn_endpoint.id} --target-network-cidr 0.0.0.0/0 --authorize-all-groups"
  }
}

resource "null_resource" "vpn_configuration" {
  depends_on = [aws_ec2_client_vpn_endpoint.vpn_endpoint]
  provisioner "local-exec" {
    command = "aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.vpn_endpoint.id} --output text >vpn-client-config.ovpn"
  }
}

resource "null_resource" "vpn_configuration_edit" {
  depends_on = [null_resource.vpn_configuration]
  provisioner "local-exec" {
    command = "[ -f ${var.client_cert_private_key_path} ] && echo 'key ${var.client_cert_private_key_path}' >>vpn-client-config.ovpn"
  }
  provisioner "local-exec" {
    command = "[ -f ${var.client_cert_public_key_path} ] && echo 'cert ${var.client_cert_public_key_path}' >>vpn-client-config.ovpn"
  }
}
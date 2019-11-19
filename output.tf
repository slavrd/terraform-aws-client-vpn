output "aws_ec2_client_vpn_endpoint_id" {
    value =  aws_ec2_client_vpn_endpoint.vpn_endpoint.id
}

output "aws_ec2_client_vpn_endpoint_address" {
    value =  aws_ec2_client_vpn_endpoint.vpn_endpoint.dns_name
}
package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAWSClientVPN(t *testing.T) {

	// terraform.Options to use for creating VPC and subnets only
	optTarget := &terraform.Options{
		TerraformDir: "./",
		NoColor:      true,
		Targets:      []string{"module.aws_basic_nw"},
	}

	// general terraform options
	opt := &terraform.Options{
		TerraformDir: "./",
		NoColor:      true,
	}

	defer func() {
		terraform.Destroy(t, opt)
		os.Remove("vpn-client-config.ovpn")
	}()

	// need to create the VPC and subnets before calling the VPN module.
	// The VPN module uses "for_each" to create VPN accusations and so all subnet ids need to be known before creating it.
	_, err := terraform.InitAndApplyE(t, optTarget)
	if err != nil {
		t.Fatalf("Failed creating basic network infrastructure: %v", err)
	}

	// apply the VPN configuration
	_, err = terraform.ApplyE(t, opt)
	if err != nil {
		t.Fatalf("Failed creating client VPN: %v", err)
	}

	// check if the VPN id output is not empty
	vpnID := terraform.Output(t, opt, "aws_ec2_client_vpn_endpoint_id")
	if vpnID == "" {
		t.Fatal("output 'aws_ec2_client_vpn_endpoint_id' was empty")
	}

	// check if the VPN client config file is present
	info, err := os.Stat("vpn-client-config.ovpn")
	if err != nil {
		t.Fatalf("error reading vpn client config file: %v", err)
	}
	if info.IsDir() {
		t.Fatal("vpn-client-config.ovpn is directory")
	}
}

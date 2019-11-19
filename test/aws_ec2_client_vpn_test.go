package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAWSClientVPN(t *testing.T) {

	optTarget := &terraform.Options{
		TerraformDir: "./",
		NoColor:      true,
		Targets:      []string{"module.aws_basic_nw"},
	}

	opt := &terraform.Options{
		TerraformDir: "./",
		NoColor:      true,
	}

	defer terraform.Destroy(t, opt)

	_, err := terraform.InitAndApplyE(t, optTarget)
	if err != nil {
		t.Fatalf("Failed creating basic network infrastructure: %v", err)
	}

	_, err = terraform.ApplyE(t, opt)
	if err != nil {
		t.Fatalf("Failed creating client VPN: %v", err)
	}

	vpnID := terraform.Output(t, opt, "aws_ec2_client_vpn_endpoint_id")
	if vpnID == "" {
		t.Fatal("output 'aws_ec2_client_vpn_endpoint_id' was empty")
	}

	info, err := os.Stat("vpn-client-config.ovpn")
	// _, err = ioutil.ReadFile("vpn-client-config.ovpn")
	if err != nil {
		t.Fatalf("error reading vpn client config file: %v", err)
	}
	if info.IsDir() {
		t.Fatal("vpn-client-config.ovpn is directory")
	}
}

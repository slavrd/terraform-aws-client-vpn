# Terraform AWS Client VPN

A terraform module to create an AWS Client VPN. 

The client vpn is set to use certificate-authentication and so requires a server and client certificates to be provided.
The certificates can be provided either via an AWS ACM arn or via local files containing the public/private keys. If the local files approach is used the certificates will be imported in AWS ACM.
An example of certificate generation can be found [here](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/authentication-authorization.html#mutual)  

## Usage

General help on using terraform modules can be found [here](https://www.terraform.io/docs/configuration/modules.html).

The available input variables are defined `variables.*.tf` files. Read their description for details about each one.

The Open VPN configuration file `vpn-client-config.ovpn` will be created in terraform's working directory. If local certificate file paths were provided for the client certificate variables their paths will be appended to the configuration. In case the files were not provided the configuration file needs to be manually edited by adding the following lines:

```
key /path/to/client/cert/private/key
cert /path/to/client/cert/public/key
```

## Known issues and limitation

* Since terraform AWS provider currently lacks resources for EC2 client vpn authorization and route these are created using `local-exec` provisioner and AWS CLI. Because of this the AWS CLI needs to be installed on the machine running terraform.
* Connection log option cannot be set to `true` as passing logging configuration is not implemented.
* Cannot use the active directory authentication option.

## Testing with terratest

The module includes a [terratest](https://github.com/gruntwork-io/terratest) test.

The test uses this [terraform-aws-basic-infrastructure](https://github.com/slavrd/terraform-aws-basic-network) module to provision a VPC and a subnet. It then calls the VPN module to build the client VPN.

The terraform code for the test is in `test/fixture.tf`. The parameters of the created AWS resources for the test can be adjusted there.

To run the test:

1. Install Golang >= 1.13 if not already installed.
2. Make sure AWS access is configured via environment variables or cli configuration file (AWS_REGION environment variable is still needed in this case)
3. run `go get -v -d -t ./test/...` to install prerequisite golang packages if not already installed.
4. run `go test -v -timeout 30m ./test/` to execute tests



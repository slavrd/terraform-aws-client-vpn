variable "server_cert_arn" {
  type        = string
  description = "ARN of the server ACM certifiacte to use for the VPN endpoint. Alternatively a local certificate can be provided which the module will import in ACM."
  default     = null
}

variable "server_cert_public_key_path" {
  type        = string
  description = "Path to the public key of the server certificate to import in AWS ACM. Ignored if server_cert_arn is set."
  default     = null
}

variable "server_cert_private_key_path" {
  type        = string
  description = "Path to the public key of the server certificate to import in AWS ACM. Ignored if server_cert_arn is set."
  default     = null
}

variable "server_cert_chain_path" {
  type        = string
  description = "Path to chain certificates to include with the server certificate. Ignored if server_cert_arn is set."
  default     = null
}

variable "client_cert_arn" {
  type        = string
  description = "ARN of the client ACM certifiacte to use for the VPN endpoint. Alternatively a local certificate can be provided which the module will import in ACM."
  default     = null
}

variable "client_cert_private_key_path" {
  type        = string
  description = "Path to the private key of the client certificate to import in AWS ACM. Will be added to the generated open-vpn config and so should use absolute path.."
  default     = null
}

variable "client_cert_public_key_path" {
  type        = string
  description = "Path to the public key of the client certificate to import in AWS ACM. Will be added to the generated open-vpn config and so should use absolute path."
  default     = null
}

variable "client_cert_chain_path" {
  type        = string
  description = "Path to chain certificates to include with the client certificate. Ignored if client_cert_arn is set."
  default     = null
}

variable "client_vpn_cidr" {
  type        = string
  description = "CIDR for the client VPN. The IP address range cannot overlap with the target network or any of the routes that will be associated with the Client VPN endpoint. The client CIDR range must have a block size that is between /16 and /22 and not overlap with VPC CIDR or any other route in the route table."
}

variable "transport_protocol" {
  type        = string
  description = "The client VPN transport protocol. Accepted vaules are UDP or TCP. Defaults to UDP"
  default     = null
}

variable "logging_enable" {
  type        = bool
  description = "NOT IMPLEMENTED! USE DEFAULT! Wheather to enable VPN connection logging."
  default     = false
}

variable "associated_subnet_ids" {
  type        = list(string)
  description = "List of subnet ids to accosiate the VPN endpoint with."
}

variable "common_tags" {
  type        = map(string)
  description = "Tags to apply to all created resources."
  default = {
    owner     = ""
    project   = ""
    terraform = "true"
  }
}

variable "name_tag_prefix" {
  type        = string
  description = "Prefix to use when naming or creating Name tag for resources."
  default     = ""
}
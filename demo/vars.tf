# Global variables

variable "location" {
  default = "Australia East"
  description = "Azure location to create resources in"
}

variable "cidr_range" {
  default = "10.1.0.0/16"
  description = "CIDR range to use as virtual network's address space"
}

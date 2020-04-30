variable "bastion_auto_scaling_group_capacity" {
  description = "Capacity of nodes in auto scaling group for bastion"
  type        = number
  default     = 1
}

variable "web_auto_scaling_group_capacity" {
  description = "Capacity of nodes in auto scaling group for web app"
  type        = number
  default     = 1
}

variable "bastion_auth" {
  description = "Allowed secutiry group bastion name"
  type = string
  default = "bastion_auth"
}

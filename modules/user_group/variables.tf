variable "region" {
  description = "Region Aws only"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  type = string
}

variable "statements" {
  type = list
  default = []
}

variable "path" {
  type = string
  default = "/"
}

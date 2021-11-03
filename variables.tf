variable "project_name" {
  description = "Project Name."
  default     = "my-site"
  type        = string
}

variable "region" {
  description = "Region in which to build the resource."
  default     = "us-east-1"
  type        = string
}

variable "host_zone_id" {
  description = "HostZone id."
  type        = string
}

variable "root_domain" {
  description = "Root Domain"
  type        = string
}

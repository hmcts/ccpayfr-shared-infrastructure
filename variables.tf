variable "product" {
  type = string
  default = "ccpay"
}

variable "core_product" {
  type    = string
  default = "ccpay"
}

variable "location" {
  type    = string
  default = "UK South"
}

variable "env" {
  type = string
}

variable "subscription" {
  type    = string
}

variable "ilbIp" {}

variable "tenant_id" {
  description = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. This is usually sourced from environemnt variables and not normally required to be specified."
}

variable "jenkins_AAD_objectId" {
  description = "(Required) The Azure AD object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}

variable "common_tags" {
  type = map(string)
}
variable "team_name" {
  type = string
  description = "Team Name"
  default = "cc-payments"
}

variable "team_contact" {
  default = "#cc-payments-tech "
}
variable "application_type" {
  type = string
  default = "web"
  description = "Type of Application Insights (Web/Other)"
}

variable "managed_identity_object_id" {
  default = ""
}

variable "fr_product" {
  type = string
  default = "fees-register"
}

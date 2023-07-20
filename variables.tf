variable "product" {
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
  type = string
}

variable "tenant_id" {
  description = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. This is usually sourced from environemnt variables and not normally required to be specified."
}

variable "jenkins_AAD_objectId" {
  description = "(Required) The Azure AD object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}

variable "common_tags" {
  type = map(any)
}

variable "team_name" {
  type        = string
  description = "Team Name"
  default     = "cc-payments"
}

variable "team_contact" {
  default = "#fee-pay-nightly-pipeline"
}
variable "application_type" {
  type        = string
  default     = "web"
  description = "Type of Application Insights (Web/Other)"
}

variable "health_check" {
  default     = "/health"
  description = "endpoint for healthcheck"
}

variable "managed_identity_object_id" {
  default = ""
}

variable "fr_product" {
  type    = string
  default = "fees-register"
}

variable "sku" {
  type        = string
  default     = "Standard"
  description = "SKU type(Basic, Standard and Premium)"
}

variable "aks_subscription_id" {}
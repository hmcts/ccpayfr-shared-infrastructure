variable "product" {
  type    = "string"
  default = "ccpay"
}

variable "location" {
  type    = "string"
  default = "UK South"
}

variable "env" {
  type    = "string"
  default = "hmctsdemo"
}

variable "subscription" {
  type    = "string"
  default = "hmctsdemo"
}

variable "tenant_id" {
  description = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. This is usually sourced from environemnt variables and not normally required to be specified."
}

variable "jenkins_AAD_objectId" {
  description = "(Required) The Azure AD object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}

variable "common_tags" {
  type = "map"
}

variable "team_name" {
  default = "cc-payments"
}

variable "team_contact" {
  default = "#cc-payments-tech "
}

variable "fees-register-frontend_external_hostname" {
  default = "fees-register.hmctsdemo.platform.hmcts.net"
}

variable "fees-register-frontend_external_cert_name" {
  default = "external-cert"
}

variable "fees-register-frontend_external_cert_vault_uri" {
  default = "https://ccpay-hmctsdemo.vault.azure.net/"
}

variable "ilbIp" {}

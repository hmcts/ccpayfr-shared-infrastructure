data "azurerm_key_vault_secret" "fees-register-frontend-cert" {
  name = "${var.fees-register-frontend_external_cert_name}"
  vault_uri = "${var.fees-register-frontend_external_cert_vault_uri}"
}

locals {
  fees-register-frontend_cert_suffix = "${var.env != "prod" ? "-fees-register-frontend" : ""}"
}

//APPLICATION GATEWAY RESOURCE FOR ENV=A
module "appGwSouth" {
  source = "git@github.com:hmcts/cnp-module-waf?ref=stripDownWf"
  env = "${var.env}"
  subscription = "${var.subscription}"
  location = "${var.location}"
  wafName = "${var.product}"
  resourcegroupname = "${azurerm_resource_group.rg.name}"

  # vNet connections
  gatewayIpConfigurations = [
    {
      name = "internalNetwork"
      subnetId = "${data.azurerm_subnet.subnet_a.id}"
    },
  ]

  sslCertificates = [
    {
      name = "${var.fees-register-frontend_external_cert_name}${local.fees-register-frontend_cert_suffix}"
      data = "${data.azurerm_key_vault_secret.fees-register-frontend-cert.value}"
      password = ""
    }
  ]

  # Http Listeners
  httpListeners = [
    # fees-register-frontend
    {
      name = "fees-register-frontend-http-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort = "frontendPort80"
      Protocol = "Http"
      SslCertificate = ""
      hostName = "${var.fees-register-frontend_external_hostname}"
    },
    {
      name = "fees-register-frontend-https-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort = "frontendPort443"
      Protocol = "Https"
      SslCertificate = "${var.fees-register-frontend_external_cert_name}${local.fees-register-frontend_cert_suffix}"
      hostName = "${var.fees-register-frontend_external_hostname}"
    }
  ]

  # Backend address Pools
  backendAddressPools = [
    {
      name = "${var.product}-${var.env}"

      backendAddresses = [
        {
          fqdn = "${var.ilbIp}"
        },
      ]
    },
  ]

  backendHttpSettingsCollection = [
    {
      name = "backend-80"
      port = 80
      Protocol = "Http"
      CookieBasedAffinity = "Disabled"
      AuthenticationCertificates = ""
      probeEnabled = "True"
      probe = "fees-register-frontend-http-probe"
      PickHostNameFromBackendAddress = "False"
      HostName = "${var.fees-register-frontend_external_hostname}"
    },
    {
      name = "backend-443"
      port = 443
      Protocol = "Https"
      CookieBasedAffinity = "Disabled"
      AuthenticationCertificates = "ilbCert"
      probeEnabled = "True"
      probe = "fees-register-frontend-https-probe"
      PickHostNameFromBackendAddress = "False"
      Host = "${var.fees-register-frontend_external_hostname}"

    }
  ]
  # Request routing rules
  requestRoutingRules = [
    # fees-register-frontend
    {
      name = "fees-register-frontend-http"
      RuleType = "Basic"
      httpListener = "fees-register-frontend-http-listener"
      backendAddressPool = "${var.product}-${var.env}"
      backendHttpSettings = "backend-80"
    },
    {
      name = "fees-register-frontend-https"
      RuleType = "Basic"
      httpListener = "fees-register-frontend-https-listener"
      backendAddressPool = "${var.product}-${var.env}"
      backendHttpSettings = "backend-443"
    }
  ]

  probes = [
    # fees-register-frontend
    {
      name = "fees-register-frontend-http-probe"
      protocol = "Http"
      path = "/"
      interval = 30
      timeout = 30
      unhealthyThreshold = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings = "backend-80"
      host = "${var.fees-register-frontend_external_hostname}"
      healthyStatusCodes = "200-399"
    },
    {
      name = "fees-register-frontend-https-probe"
      protocol = "Https"
      path = "/"
      interval = 30
      timeout = 30
      unhealthyThreshold = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings = "backend-443"
      host = "${var.fees-register-frontend_external_hostname}"
      healthyStatusCodes = "200-399"
    }
  ]
}
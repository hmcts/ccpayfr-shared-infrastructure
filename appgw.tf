locals {
  backend_address_pool = "${var.product}-${var.env}"
  paybubble_backend_hostname = "ccpay-bubble-frontend-${var.env}.service.core-compute-${var.env}.internal"
}

data "azurerm_key_vault_secret" "paybubble-cert" {
  name = "${var.pay_bubble_external_cert_name}"
  vault_uri = "${var.pay_bubble_external_cert_vault_uri}"
}

//APPLICATION GATEWAY RESOURCE FOR ENV=A
module "appGwSouth" {
  source = "git@github.com:hmcts/cnp-module-waf?ref=master"
  env = "${var.env}"
  subscription = "${var.subscription}"
  location = "${var.location}"
  wafName = "${var.product}"
  resourcegroupname = "${azurerm_resource_group.rg.name}"
  common_tags = "${var.common_tags}"
  use_authentication_cert = true

  # vNet connections
  gatewayIpConfigurations = [
    {
      name = "internalNetwork"
      subnetId = "${data.azurerm_subnet.subnet_a.id}"
    },
  ]

  sslCertificates = [
    {
      name = "${var.pay_bubble_external_cert_name}"
      data = "${data.azurerm_key_vault_secret.paybubble-cert.value}"
      password = ""
    }
  ]

  # Http Listeners
  httpListeners = [
    # paybubble
    {
      name = "pay-bubble-http-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort = "frontendPort80"
      Protocol = "Http"
      SslCertificate = ""
      hostName = "${var.pay_bubble_external_hostname}"
    },
    {
      name = "pay-bubble-https-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort = "frontendPort443"
      Protocol = "Https"
      SslCertificate = "${var.pay_bubble_external_cert_name}"
      hostName = "${var.pay_bubble_external_hostname}"
    },
    {
      name = "pay-bubble-https-listener-www"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort = "frontendPort443"
      Protocol = "Https"
      SslCertificate = "${var.pay_bubble_external_cert_name}"
      hostName = "${var.pay_bubble_external_hostname_www}"
    }
  ]

  # Backend address Pools
  backendAddressPools = [
    {
      name = "${local.backend_address_pool}"

      backendAddresses = [
        {
          ipAddress = "${local.paybubble_backend_hostname}"
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
      probe = "pay-bubble-http-probe"
      PickHostNameFromBackendAddress = "False"
      HostName = "${var.pay_bubble_external_hostname}"
    },
    {
      name = "backend-443"
      port = 443
      Protocol = "Https"
      CookieBasedAffinity = "Disabled"
      AuthenticationCertificates = "ilbCert"
      probeEnabled = "True"
      probe = "pay-bubble-https-probe"
      PickHostNameFromBackendAddress = "False"
      HostName = "${var.pay_bubble_external_hostname}"
    },
    {
      name = "backend-443-www"
      port = 443
      Protocol = "Https"
      CookieBasedAffinity = "Disabled"
      AuthenticationCertificates = "ilbCert"
      probeEnabled = "True"
      probe = "pay-bubble-https-probe-www"
      PickHostNameFromBackendAddress = "False"
      HostName = "${var.pay_bubble_external_hostname_www}"
    }
  ]
  # Request routing rules
  requestRoutingRules = [
    # pay bubble
    {
      name = "pay-bubble-http"
      RuleType = "Basic"
      httpListener = "pay-bubble-http-listener"
      backendAddressPool = "${local.backend_address_pool}"
      backendHttpSettings = "backend-80"
    },
    {
      name = "pay-bubble-https"
      RuleType = "Basic"
      httpListener = "pay-bubble-https-listener"
      backendAddressPool = "${local.backend_address_pool}"
      backendHttpSettings = "backend-443"
    },
    {
      name = "pay-bubble-https-www"
      RuleType = "Basic"
      httpListener = "pay-bubble-https-listener-www"
      backendAddressPool = "${local.backend_address_pool}"
      backendHttpSettings = "backend-443-www"
    }
  ]

  probes = [
    # pay bubble
    {
      name = "pay-bubble-http-probe"
      protocol = "Http"
      path = "${var.health_check}"
      interval = 30
      timeout = 30
      unhealthyThreshold = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings = "backend-80"
      host = "${var.pay_bubble_external_hostname}"
      healthyStatusCodes = "200-404"
    },
    {
      name = "pay-bubble-https-probe"
      protocol = "Https"
      path = "${var.health_check}"
      interval = 30
      timeout = 30
      unhealthyThreshold = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings = "backend-443"
      host = "${var.pay_bubble_external_hostname}"
      healthyStatusCodes = "200-404" // MS returns 404 on /, allowing more codes in case they change it
    },
    {
      name = "pay-bubble-https-probe-www"
      protocol = "Https"
      path = "${var.health_check}"
      interval = 30
      timeout = 30
      unhealthyThreshold = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings = "backend-443-www"
      host = "${var.pay_bubble_external_hostname_www}"
      healthyStatusCodes = "200-404" // MS returns 404 on /, allowing more codes in case they change it
    }
  ]
}

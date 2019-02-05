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
      name = "pay-bubble-frontend-http-listener"
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
      Host = "${var.pay_bubble_external_hostname}"

    }
  ]
  # Request routing rules
  requestRoutingRules = [
    # pay bubble
    {
      name = "pay-bubble-http"
      RuleType = "Basic"
      httpListener = "pay-bubble-http-listener"
      backendAddressPool = "${var.product}-${var.env}"
      backendHttpSettings = "backend-80"
    },
    {
      name = "pay-bubble-https"
      RuleType = "Basic"
      httpListener = "pay-bubble-https-listener"
      backendAddressPool = "${var.product}-${var.env}"
      backendHttpSettings = "backend-443"
    }
  ]

  probes = [
    # pay bubble
    {
      name = "pay-bubble-http-probe"
      protocol = "Http"
      path = "/"
      interval = 30
      timeout = 30
      unhealthyThreshold = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings = "backend-80"
      host = "${var.pay_bubble_external_hostname}"
      healthyStatusCodes = "200-399"
    },
    {
      name = "pay-bubble-https-probe"
      protocol = "Https"
      path = "/"
      interval = 30
      timeout = 30
      unhealthyThreshold = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings = "backend-443"
      host = "${var.pay_bubble_external_hostname}"
      healthyStatusCodes = "200-399"
    }
  ]
}
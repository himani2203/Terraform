locals {
  fapp_name = azurerm_linux_function_app.function_app.name
  username = azurerm_linux_function_app.function_app.site_credential[0].name
  password = azurerm_linux_function_app.function_app.site_credential[0].password
}

resource "azurerm_container_registry_webhook" "webhook" {
  count = var.enable_webhooks ? 1 : 0
  name                = replace(local.fapp_name, "-", "")

  resource_group_name = azurerm_resource_group.resource_group.name
  registry_name       = azurerm_container_registry.acr.name
  location            = azurerm_resource_group.resource_group.location

  service_uri = format("https://%s:%s@%s.scm.azurewebsites.net/docker/hook", local.username, local.password, local.fapp_name)
  status      = "enabled"
  scope       = "${var.image}:${var.environment.metadata.sequence}"
  actions     = ["push"]
  custom_headers = merge({
    "Content-Type" = "application/json"
  })
}
#This is for Creating Service Connection using Docker regsitry

resource "azuread_application" "acr_push" {
  display_name = "${azurerm_container_registry.acr}sp"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "acr_push" {
  application_id               = azuread_application.acr_push.application_id
  owners                       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "acr_push" {
  service_principal_id = azuread_service_principal.acr_push.id
}

output "acr_username" {
  value = azuread_application.acr_push.application_id
}

output "acr_password" {
  value = azuread_service_principal_password.acr_push.value
  sensitive = true
}

#ACR Role to push Docker Image from Azure DevOps

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = dazuread_service_principal.acr_push.id
}
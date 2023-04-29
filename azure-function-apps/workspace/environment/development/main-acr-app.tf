#This Service Principal will be used for creating Service Connection using Docker regsitry in Azure DevOps

#Please note our Enterprise Application must have below API Persmission to create SP and assign roles else it will throw 403 error (ApplicationsClient.BaseClient.Post(): unexpected status 403 with OData error: Authorization_RequestDenied:
# Insufficient privileges to complete the operation.)
#API NAME: Microsoft Graph
#Claim Value: Application.ReadWrite.OwnedBy , Directory.Read.All, Application.Read.All


resource "azuread_application" "acr_push" {
  display_name = "${azurerm_container_registry.acr.name}sp"
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

#ACR Role to push Docker Image from Azure DevOps Pipeline

resource "azurerm_role_assignment" "acr_sp_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.acr_push.id
}

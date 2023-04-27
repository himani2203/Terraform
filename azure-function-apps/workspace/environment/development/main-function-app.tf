module "storage_service_endpoint" {
  source = "../../modules/subnet-findby-service-endpoint"

  virtual_network = data.azurerm_virtual_network.network
  service_endpoint = "Microsoft.Storage"
}

resource "azurerm_storage_account" "storage" {
  name                = replace(format("sacc-%s", local.name), "-", "")

  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
  public_network_access_enabled = true

  network_rules {
    default_action             = "Allow"
    ip_rules                   = flatten([var.WhiteListedCIDRRange])
    virtual_network_subnet_ids = flatten([[for subnet in module.storage_service_endpoint.subnet : subnet.id]])
    bypass = ["Metrics", "AzureServices", "Logging"]
  }

  tags = local.resource_tags
}

resource "azurerm_service_plan" "asp_plan" {
  name                = format("aspl-%s", local.name)
  
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  os_type             = "Linux"
  sku_name            = "EP1"
}

resource "azurerm_linux_function_app" "function_app" {
  name                = format("fapp-%s", local.name)
  
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  service_plan_id            = azurerm_service_plan.asp_plan.id
  https_only = true

  app_settings = {
    WEBSITES_PORT = 5000
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = true
  }

  site_config {
    container_registry_use_managed_identity = true
    application_stack {
      docker {
        registry_url = azurerm_container_registry.acr.login_server
        image_name = var.image
        image_tag = var.environment.metadata.sequence
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

#Function App Role to pull image from ACR

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_function_app.function_app.identity[0].principal_id
}

output "function-app" {
  value = azurerm_linux_function_app.function_app
  sensitive = true
}
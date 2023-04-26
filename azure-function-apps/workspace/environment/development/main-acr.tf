module "service_endpoint" {
  source = "../../modules/subnet-findby-service-endpoint"

  virtual_network = data.azurerm_virtual_network.network
  service_endpoint = "Microsoft.ContainerRegistry"
}

resource "azurerm_container_registry" "acr" {

  name                = replace(format("creg-%s", local.name), "-", "")

  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  sku                 = "Premium"
  admin_enabled       = false
    
  georeplications {
    location                = "Central US"
    zone_redundancy_enabled = true
    tags                    = local.resource_tags
  }

  trust_policy {
    enabled = true
  }

  retention_policy {
    days = 14
    enabled = true
  }

  anonymous_pull_enabled = true
  public_network_access_enabled = true
  network_rule_bypass_option = "AzureServices"

  network_rule_set {
    default_action = "Allow"

    ip_rule = flatten([
        [
            for i in range(length(var.WhiteListedCIDRRange)) : {
                action = "Allow"
                ip_range = var.WhiteListedCIDRRange[i]
            }
        ],
    ])

    virtual_network = flatten([[for subnet in module.service_endpoint.subnet :
        {
            action = "Allow"
            subnet_id = subnet.id
        }
    ]])
  }

  tags = local.resource_tags
}

output "acr" {
  value = azurerm_container_registry.acr
  sensitive = true
}
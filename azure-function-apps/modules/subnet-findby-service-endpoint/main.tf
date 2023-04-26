data "azurerm_subnet" "network" {
    count = length(var.virtual_network.subnets)
    name = var.virtual_network.subnets[count.index]

    virtual_network_name = var.virtual_network.name
    resource_group_name  = var.virtual_network.resource_group_name
}

output "subnet" {
  value = [for subnet in data.azurerm_subnet.network : subnet if contains(subnet.service_endpoints, var.service_endpoint)]
}
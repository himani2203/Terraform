#Assuming VNET is already created and have subnets

data "azurerm_virtual_network" "network" {
  name                = "vnet_name"
  resource_group_name = "vnet_rg_name"
}

data "azurerm_client_config" "current" {}

locals {
  name = format("%s%s-%s%s", var.resource.naming.environment, var.resource.naming.region, var.environment.metadata.primary_key, var.environment.metadata.sequence)
  resource_tags = merge(var.resource.tags, {
    environment : var.resource.naming.environment,
    sequence : var.environment.metadata.sequence, identifier : var.environment.metadata.primary_key, namespace : var.environment.metadata.source
  })
}

resource "azurerm_resource_group" "resource_group" {
  name     = format("rgrp-%s", local.name)

  location = "eastus2"
  tags = local.resource_tags
}

resource "azurerm_management_lock" "subscription-level" {
  name       = format("rgrp-%s-lock", local.name)
  scope      = azurerm_resource_group.resource_group.id

  lock_level = "CanNotDelete"
  notes      = "Resource Group Is Locked"

  lifecycle {
    ignore_changes = [notes]
  }
}
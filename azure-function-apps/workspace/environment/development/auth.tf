terraform {
  backend "azurerm" {
    key = "dva2-npdev000.tfstate"
    resource_group_name  = "StorageAccount-ResourceGroup"
    storage_account_name = "storageaccountname"
    container_name       = "terraform-state"
  }

  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      version = "2.31.0"
    }

    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.35.0"
    }

  }

}


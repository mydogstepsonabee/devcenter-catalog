terraform {
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
      }
    }
}

provider "azurerm" {
  subscription_id = "69a4fcb5-0c29-4144-80e6-0093faa42fbe"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-functionapp-demo"
  location = "Japan East"
}

# Create a storage account (required for Function Apps)
resource "azurerm_storage_account" "storage" {
  name                     = "devboxfuncxhu543" # Must be unique
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create an app service plan for consumption
resource "azurerm_service_plan" "consumption_plan" {
  name                = "function-app-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type = "Linux"
  sku_name = "Y1"


}

# Create a Function App
resource "azurerm_linux_function_app" "function_app" {
  name                       = "devboxfuncxhu543"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id        = azurerm_service_plan.consumption_plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
site_config {
  
}
  # Application settings
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "node" # Change runtime (e.g., "node", "python", "dotnet", etc.)
  }

  # Optional Identity for the Function App
  identity {
    type = "SystemAssigned"
  }
}
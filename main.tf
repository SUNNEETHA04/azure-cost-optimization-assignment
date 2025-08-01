# main.tf
# Configure the Azure Provider and create a Resource Group

provider "azurerm" {
  features {}
}

# Generate a random suffix to make resource names unique
resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

# Create a Resource Group to contain all resources
resource "azurerm_resource_group" "rg" {
  name     = "rg-cost-optimization"
  location = "East US"
}

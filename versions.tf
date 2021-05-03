terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  # backend "remote"{
  #   organization = "donggalland"
  #   workspaces{
  #     name = "TerraformStateTest"
  #   }
  # }

  required_version = ">= 0.13"
}

provider "azurerm"{
  version = "~>2.0"
  features {}
}

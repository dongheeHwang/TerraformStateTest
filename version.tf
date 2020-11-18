terraform {
  backend "remote"{
    organization = "donggalland"
    workspaces{
      name = "TerraformState"
    }
  }
}

# 공급자 설정.
provider "azurerm"{
  version = "~>2.0"
  features {}
}
terraform {
  // 서비스 주체자 등록할때,  Subscription 및 전역관리자 RBAC 설정 필요!
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
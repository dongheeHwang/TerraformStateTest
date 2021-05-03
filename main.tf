locals {
  iam_rg_list = concat(var.iam_rg_list)
}

# terraform-wvdsync-rg 리소스 그룹 생성
resource "azurerm_resource_group" "wvdsync" {
  name     = var.wvdsync_resource_group
  location = "KoreaCentral"
}

data "azurerm_resource_group" "vm"{
  name = var.vm_resource_group
}

data "azurerm_resource_group" "sessionhost"{
  name = var.sessionhost_resource_group
}


# terraform-wvdsync-rg 리소스 그룹내에
# wvdsyncdongheesa 스토리지 계정 생성
resource "azurerm_storage_account" "wvdsync" {
  name                     = "wvdsync${var.company_name}stg"
  resource_group_name      = azurerm_resource_group.wvdsync.name
  location                 = azurerm_resource_group.wvdsync.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# terraform-wvdsync-rg 리소스 그룹내에
# wvdsync-service-plan 서비스 계획 생성
resource "azurerm_app_service_plan" "wvdsync" {
  name                = "wvdsync-${var.company_name}-service-plan"
  location            = azurerm_resource_group.wvdsync.location
  resource_group_name = azurerm_resource_group.wvdsync.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

# Azure Active Directory에 wvdsync-app 등록
resource "azuread_application" "wvdsync" {
  name                       = "wvdsync-${var.company_name}-app"
  
  # functionapp 과 application의 순환참조 오류가 발생되어, 상수로 입력.
  homepage                   = "https://wvdsync-${var.company_name}.azurewebsites.net"
  identifier_uris            = ["https://wvdsync-${var.company_name}.azurewebsites.net"]
  reply_urls                 = ["https://login.microsoftonline.com/common/oauth2/nativeclient", "https://wvdsync-${var.company_name}.azurewebsites.net/.auth/login/aad/callback"]
  type                       = "webapp/api"
  # required_resource_access {
  #   resource_app_id = "${self.application_id}"

  #   resource_access {
  #     id   = data.azuread_application.wvdsync.oauth2_permissions[0].id
  #     type = "Role"
  #   }
  # }
}

# resource "azuread_application_oauth2_permission" "user_impersonation" {
#   application_object_id = azuread_application.wvdsync.id
#   admin_consent_description  = "Allow the application to access ${azuread_application.wvdsync.name} on behalf of the signed-in user."
#   admin_consent_display_name = "Access ${azuread_application.wvdsync.name}"
#   is_enabled                 = true
#   type                       = "User"
#   user_consent_description   = "Allow the application to access ${azuread_application.wvdsync.name} on your behalf."
#   user_consent_display_name  = "Access ${azuread_application.wvdsync.name}"
#   value                      = "user_impersonation"
#   depends_on = [ azuread_application.wvdsync ]
# }

# Azure Active Directory에 wvdsync-app을 서비스 주체자로 설정.
resource "azuread_service_principal" "wvdsync" {
  application_id               = azuread_application.wvdsync.application_id
  app_role_assignment_required = false
}

# SystemAssigned된 FunctionApp에 Identity Access Manager를 설정.
data "azurerm_resource_group" "iams" {
  count = length(local.iam_rg_list)
  name = local.iam_rg_list[count.index]
}

resource "azurerm_role_assignment" "iams" {
  count = length(data.azurerm_resource_group.iams)

  scope = data.azurerm_resource_group.iams[count.index].id
  role_definition_name  = "Contributor"
  principal_id          = azurerm_function_app.wvdsync.identity[0].principal_id
}

resource "azurerm_role_assignment" "wvdsync" {
  scope                 = azurerm_resource_group.wvdsync.id
  role_definition_name  = "Contributor"
  principal_id          = azurerm_function_app.wvdsync.identity[0].principal_id
}

# azure에서 구독 정보를 가져온다.
data "azurerm_subscription" "current" {
}

# resource "azurerm_app_service_source_control_token" "repo" {
#   type  = "GitHub"
#   token = "cd0f239fbf78136466209d32ada77c64badaf885"
# }

# terraform-wvdsync-rg 리소스 그룹내에
# FunctionApp wvdsync를 등록한다.
resource "azurerm_function_app" "wvdsync" {
  name                       = "wvdsync-${var.company_name}"
  location                   = azurerm_resource_group.wvdsync.location
  resource_group_name        = azurerm_resource_group.wvdsync.name
  app_service_plan_id        = azurerm_app_service_plan.wvdsync.id
  storage_account_name       = azurerm_storage_account.wvdsync.name
  storage_account_access_key = azurerm_storage_account.wvdsync.primary_access_key
  version                    = "~3"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME                    = "dotnet"
    FUNCTIONS_EXTENSION_VERSION                 = "~3"
    SUBSCRIPTION                                = data.azurerm_subscription.current.subscription_id
    TANENTE                                     = data.azurerm_subscription.current.tenant_id
    VM_RESOURCEGROUP                            = var.vm_resource_group
    SESSIONHOST_RESOURCEGROUP                   = var.sessionhost_resource_group
    START_VM_PROTECT_MIN                        = "10"
    STORAGE_TABLE_CONNECTSTRING                 = azurerm_storage_account.wvdsync.primary_connection_string
    STORAGE_TABLE_NAME                          = "WVDSync${var.company_name}"
    STORAGE_WEBHOOK                             = ""
    UTC_HOUR_OFFSET                             = "9"
    "AzureWebJobs.AutoPooling.Disabled"         = "true"
    "AzureWebJobs.AutoStop.Disabled"            = "true"
  }

  identity {
    type = "SystemAssigned"
  }

  auth_settings {
    enabled = true
    default_provider = "AzureActiveDirectory"
    active_directory {
      client_id = azuread_application.wvdsync.application_id
      allowed_audiences = ["https://wvdsync-${var.company_name}.azurewebsites.net"]
    }
  }

  # source_control {
  #   repo_url = "https://github.com/dongheeHwang/WVDSync.Git"
  #   branch = "main"
  # }
}

output "base_uri" {
  # value = [
  #   for identifier_uri in azuread_application.wvdsync.identifier_uris:
  #   identifier_uri
  # ]
  value = azuread_application.wvdsync.identifier_uris[*]
}

output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}

output "application_id" {
  value = azuread_application.wvdsync.application_id
}
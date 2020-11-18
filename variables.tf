variable "company_name"{
  type = string
  description = "TDGWVDSync Name"
  default = "wvddemotest"
}

variable "wvdsync_resource_group" {
  description = "wvdsync resource group name"
  default = "RG-WVDSync"
}

variable "vm_resource_group" {
  type = string
  description = "VM_RESOURCE_GROUP"
  default = "RG-DEMO"
}

variable "sessionhost_resource_group"{
  type = string
  description = "SESSIONHOST_RESOURCE_GROUP"
  default = "RG-DEMO"
}

variable "iam_rg_list" {
  type = list(string)
  description = "Resource group to Contributor IAM"
  default = ["RG-DEMO"]
}

variable "azuread_application_id" {
  type = string
  default = "afef6f76-520e-dd36-189b-28dac18aaae7"
}
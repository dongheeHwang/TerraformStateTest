variable "company_name"{
  type = string
  description = "TDGWVDSync Name"
  default = "tdgdemo"
}

variable "wvdsync_resource_group" {
  description = "wvdsync resource group name"
  default = "RG-WVDSync"
}

variable "vm_resource_group" {
  type = string
  description = "VM_RESOURCE_GROUP"
  default = "RG-WVDVM"
}

variable "sessionhost_resource_group"{
  type = string
  description = "SESSIONHOST_RESOURCE_GROUP"
  default = "RG-WVDVM"
}

variable "iam_rg_list" {
  type = list(string)
  description = "Resource group to Contributor IAM"
  default = ["RG-WVDVM"]
}
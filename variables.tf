# 고객사명 작성.
variable "company_name"{
  type = string
  description = "TDGWVDSync Name"
  default = "tdgdemo"
}

# WVDSync를 배포할 Azure 리소스 그룹명.
variable "wvdsync_resource_group" {
  description = "wvdsync resource group name"
  default = "RG-WVDSync"
}

# WVD의 VM이 배포된 리소스 그룹명.
variable "vm_resource_group" {
  type = string
  description = "VM_RESOURCE_GROUP"
  default = "RG-WVDVM"
}

# WVD의 세션호스트가 배포된 리소스 그룹명.(보통 VM리소스 그룹과 동일함.)
variable "sessionhost_resource_group"{
  type = string
  description = "SESSIONHOST_RESOURCE_GROUP"
  default = "RG-WVDVM"
}

# TDGWVDSync Function App에 기여자 권한을 부여해야하는 IAM.(WVD의 VM, 세션호스트의 리소스 그룹명을 넣어야함)
variable "iam_rg_list" {
  type = list(string)
  description = "Resource group to Contributor IAM"
  default = ["RG-WVDVM"]
}
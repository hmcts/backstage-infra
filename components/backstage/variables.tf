variable "product" {
  default = "hmcts"
}
variable "component" {
  default = "backstage"
}

variable "builtFrom" {
  default = "hmcts/backstage-infra"
}

variable "env" {
}

variable "aks_subscription_id" {}

variable "expiresAfter" {
  default = "3000-01-01"
}
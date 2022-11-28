provider "alicloud" {
  region = "ap-northeast-1"
}

data "alicloud_resource_manager_resource_groups" "default" {}

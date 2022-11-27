resource "alicloud_vpc" "this" {
  vpc_name   = "VPC"
  cidr_block = "10.0.0.0/8"
}

resource "alicloud_vswitch" "public_1a" {
  vpc_id     = alicloud_vpc.this.id
  cidr_block = "10.0.0.0/24"
  zone_id    = "ap-northeast-1a"
  depends_on = [alicloud_vpc.this]
}

resource "alicloud_vswitch" "private_1a" {
  vpc_id     = alicloud_vpc.this.id
  cidr_block = "10.0.1.0/24"
  zone_id    = "ap-northeast-1a"
  depends_on = [alicloud_vpc.this]
}

resource "alicloud_vswitch" "public_1b" {
  vpc_id     = alicloud_vpc.this.id
  cidr_block = "10.0.2.0/24"
  zone_id    = "ap-northeast-1b"
  depends_on = [alicloud_vpc.this]
}

resource "alicloud_vswitch" "private_1b" {
  vpc_id     = alicloud_vpc.this.id
  cidr_block = "10.0.3.0/24"
  zone_id    = "ap-northeast-1b"
  depends_on = [alicloud_vpc.this]
}

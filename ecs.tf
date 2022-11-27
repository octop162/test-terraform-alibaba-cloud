data "alicloud_images" "centos" {
  most_recent = true
  name_regex  = "^centos_7*"
}

resource "alicloud_security_group" "for_ecs" {
  name       = "for_ecs"
  vpc_id     = alicloud_vpc.this.id
  depends_on = [alicloud_vswitch.private_1a]
}

resource "alicloud_security_group_rule" "for_ecs" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "*"
  security_group_id = alicloud_security_group.for_ecs.id
  cidr_ip           = "10.0.0.0/8"
  depends_on        = [alicloud_security_group.for_ecs]
}

resource "alicloud_security_group_rule" "for_ecs_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.for_ecs.id
  cidr_ip           = "100.104.0.0/16"
  depends_on        = [alicloud_security_group.for_ecs]
}

resource "alicloud_security_group_rule" "for_ecs_internet" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.for_ecs.id
  cidr_ip           = "0.0.0.0/0"
  depends_on        = [alicloud_security_group.for_ecs]
}

resource "alicloud_instance" "wordpress1" {
  instance_name              = "wordpress1"
  host_name                  = "wordpress1"
  image_id                   = data.alicloud_images.centos.ids.0
  instance_type              = "ecs.g6.large"
  security_groups            = [alicloud_security_group.for_ecs.id]
  vswitch_id                 = alicloud_vswitch.private_1a.id
  internet_max_bandwidth_out = 10
  system_disk_category       = "cloud_efficiency"
  system_disk_name           = "wordpress1_disk"
  instance_charge_type       = "PostPaid"
  data_disks {
    name        = "disk"
    size        = 20
    category    = "cloud_efficiency"
    description = "disk2"
  }
  password  = "password123X&X"
  user_data = <<EOF
#!/bin/bash
yum install -y httpd
systemctl start httpd
systemctl enable httpd
EOF
}

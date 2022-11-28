data "alicloud_images" "centos" {
  most_recent = true
  name_regex  = "^centos_7"
  owners      = "system"
}

resource "alicloud_security_group" "for_ecs" {
  name       = "for_ecs"
  vpc_id     = alicloud_vpc.this.id
  depends_on = [alicloud_vswitch.private_1a, alicloud_vswitch.private_1b]
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
  instance_name                 = "wordpress1"
  host_name                     = "wordpress1"
  image_id                      = data.alicloud_images.centos.ids.0
  instance_type                 = "ecs.g6.large"
  security_groups               = [alicloud_security_group.for_ecs.id]
  vswitch_id                    = alicloud_vswitch.private_1a.id
  internet_max_bandwidth_out    = 10
  system_disk_category          = "cloud_efficiency"
  system_disk_name              = "wordpress1_disk"
  instance_charge_type          = "PostPaid"
  security_enhancement_strategy = "Deactive"
  data_disks {
    name        = "disk"
    size        = 20
    category    = "cloud_efficiency"
    description = "disk2"
  }
  password  = "password123X&X"
  user_data = <<EOF
#!/bin/bash
yum install -y epel-release
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum install -y httpd mysql
yum --enablerepo=remi-php81 install -y php php-mbstring php-xml php-mysql php-pdo
wget http://ja.wordpress.org/latest-ja.tar.gz -P /tmp/
tar zxvf /tmp/latest-ja.tar.gz -C /tmp
cp -r /tmp/wordpress/* /var/www/html/
chown apache:apache -R /var/www/html
systemctl enable httpd.service
systemctl start httpd.service
EOF
}

resource "alicloud_instance" "wordpress2" {
  instance_name                 = "wordpress2"
  host_name                     = "wordpress2"
  image_id                      = data.alicloud_images.centos.ids.0
  instance_type                 = "ecs.g6.large"
  security_groups               = [alicloud_security_group.for_ecs.id]
  vswitch_id                    = alicloud_vswitch.private_1b.id
  internet_max_bandwidth_out    = 10
  system_disk_category          = "cloud_efficiency"
  system_disk_name              = "wordpress2_disk"
  instance_charge_type          = "PostPaid"
  security_enhancement_strategy = "Deactive"
  data_disks {
    name        = "disk"
    size        = 20
    category    = "cloud_efficiency"
    description = "disk2"
  }
  password  = "password123X&X"
  user_data = <<EOF
#!/bin/bash
yum install -y epel-release
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum install -y httpd mysql
yum --enablerepo=remi-php81 install -y php php-mbstring php-xml php-mysql php-pdo
wget http://ja.wordpress.org/latest-ja.tar.gz -P /tmp/
tar zxvf /tmp/latest-ja.tar.gz -C /tmp
cp -r /tmp/wordpress/* /var/www/html/
chown apache:apache -R /var/www/html
systemctl enable httpd.service
systemctl start httpd.service
EOF
}

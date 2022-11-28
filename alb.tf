resource "alicloud_alb_load_balancer" "this" {
  vpc_id                 = alicloud_vpc.this.id
  address_type           = "Internet"
  address_allocated_mode = "Fixed"
  load_balancer_name     = "LoadBalancer"
  load_balancer_edition  = "Basic"
  resource_group_id      = data.alicloud_resource_manager_resource_groups.default.groups.0.id

  load_balancer_billing_config {
    pay_type = "PayAsYouGo"
  }
  zone_mappings {
    vswitch_id = alicloud_vswitch.public_1a.id
    zone_id    = "ap-northeast-1a"
  }
  zone_mappings {
    vswitch_id = alicloud_vswitch.public_1b.id
    zone_id    = "ap-northeast-1b"
  }
  modification_protection_config {
    status = "NonProtection"
  }
}

resource "alicloud_alb_server_group" "this" {
  protocol          = "HTTP"
  vpc_id            = alicloud_vpc.this.id
  server_group_name = "server_group"
  resource_group_id = data.alicloud_resource_manager_resource_groups.default.groups.0.id

  health_check_config {
    health_check_connect_port = 80
    health_check_enabled      = false
    health_check_host         = ""
    health_check_http_version = "HTTP1.1"
    health_check_interval     = 2
    health_check_method       = "HEAD"
    health_check_path         = "/index.php"
    health_check_protocol     = "HTTP"
    health_check_timeout      = 5
    healthy_threshold         = 3
    unhealthy_threshold       = 3
  }

  sticky_session_config {
    sticky_session_enabled = false
  }

  servers {
    description = "wordpress1"
    port        = 80
    server_id   = alicloud_instance.wordpress1.id
    server_ip   = alicloud_instance.wordpress1.private_ip
    server_type = "Ecs"
    weight      = 10
  }

  servers {
    description = "wordpress2"
    port        = 80
    server_id   = alicloud_instance.wordpress2.id
    server_ip   = alicloud_instance.wordpress2.private_ip
    server_type = "Ecs"
    weight      = 10
  }
}

resource "alicloud_alb_acl" "this" {
  acl_name          = "acl"
  resource_group_id = data.alicloud_resource_manager_resource_groups.default.groups.0.id
}

resource "alicloud_alb_listener" "alb_listener" {
  load_balancer_id     = alicloud_alb_load_balancer.this.id
  listener_protocol    = "HTTP"
  listener_port        = "80"
  listener_description = "HTTPPort"
  default_actions {
    type = "ForwardGroup"
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.this.id
      }
    }
  }
}

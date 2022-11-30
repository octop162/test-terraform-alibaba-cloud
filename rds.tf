resource "alicloud_db_instance" "this" {
  engine           = "MySQL"
  engine_version   = "8.0"
  instance_type    = "rds.mysql.s1.small"
  instance_storage = "10"
  vswitch_id       = alicloud_vswitch.private_1a.id
  instance_name    = "instance"
}

resource "alicloud_db_database" "this" {
  instance_id = alicloud_db_instance.this.id
  name        = "database"
  description = "database"
}

resource "alicloud_db_account" "this" {
  db_instance_id   = alicloud_db_instance.this.id
  account_name     = "privilege_user"
  account_password = "25SzZwL7WABU"
}

resource "alicloud_db_account_privilege" "this" {
  instance_id  = alicloud_db_instance.this.id
  account_name = alicloud_db_account.this.name
  privilege    = "ReadWrite"
  db_names     = [alicloud_db_database.this.name]
}

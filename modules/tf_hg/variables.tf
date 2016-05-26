variable "name"                  { default = "hg" }
variable "ami"                   { }
variable "instance_type"         { default = "t2.micro" }
variable "instance_profile"      { }
variable "disable_termination"   { default = false }
variable "subnet_id"             { }
variable "vpc_sg_ids"            { }
variable "public_sg_id"          { }
variable "availability_zone"     { }
variable "base_bucket"           { }
variable "logging_bucket"        { }
variable "user_data_scripts"     { default = "" }
variable "volume_size"           { }
variable "volume_type"           { default = "gp2" }
variable "device_name"           { default = "/dev/xvdg" }
variable "mount_point"           { }

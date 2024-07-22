variable "region" {
	default = "eu-west-2"
}
variable "ami" {
	default = "ami-026b2ae0ba2773e0a"
}

variable "instance_type" {
	default = "t2.micro"
}

variable "instance_name" {
	default = "Terraform-SOLR"
}

variable "s_g_name" {
	default = "DEMO_SG"
}

variable "s_g_description" {
	default = "Solr Security Group Using Terraform"
}

variable "vpc_id" {
	default = "vpc-02782f45b0219c25a"
}

variable "kp_filename" {
	default = "DEMO_KP"
}

variable "root_vol_size" {
	default = 8
}

variable "root_vol_type" {
        default = "gp3"
}

variable "root_device_name" {
        default = "/dev/xvda"
}

variable "vol_size" {
	default = 8
}

variable "volume_type" {
	default = "gp2"
}

variable "ebs_device_name" {
	default = "/dev/sdf"
}

variable "ebs_vol_name" {
	default = "DEMO_EBS_VOL"
}

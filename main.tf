# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_elb" "pocapp-elb" {
  name = "${var.region_s}-elb-${var.env}-pocapp"
  security_groups = ["${aws_security_group.elb_sg.id}"]

  # The same availability zone as our instances
  availability_zones = ["${split(",", var.availability_zones)}"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  /*listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
  #  ssl_certificate_id = "${var.server_certificate}"
  }*


  /*health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }*/
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb_sg" {
  name        = "pocapp-elb-sg"
  description = "Security group for elbs exposed to outside"

  # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }





  # outbound internet access
  /*egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }*/


}


resource "aws_opsworks_stack" "pocapp_stack" {
  name                         = "pocapp-stack"
  region                       = "${var.aws_region}"
  service_role_arn             = "${aws_iam_role.opsworks.arn}"
  default_instance_profile_arn = "${aws_iam_instance_profile.opsworks.arn}"
  #configuration_manager_version = "12"
  default_os = "Ubuntu 14.04 LTS"
  use_opsworks_security_groups = true
  default_availability_zone = "us-east-1b"
 # vpc_id = "vpc-8e4a28e8"
  
  /*tags {
    Name = "pocapp-terraform-stack"
  }*/

  custom_json = <<EOT
{
 "pocapp": {
    "version": "1.0.0"
  }
}
EOT
}

resource "aws_opsworks_nodejs_app_layer" "pocapp" {
  stack_id = "${aws_opsworks_stack.pocapp_stack.id}"
  name = "pocapp-${var.env}"
  use_ebs_optimized_instances = true
  nodejs_version = "0.12.18"
  /*ebs_volume {
    mount_point = "/app"
    type = "gp2"
    volume_size = 100
  }*/
  
}


# opsworks application

resource "aws_opsworks_application" "foo-app" {
  name        = "pocapp-opsworks-nodejs"
  short_name  = "pocapp"
  stack_id    = "${aws_opsworks_stack.pocapp_stack.id}"
  type        = "nodejs"
  description = "This is a Nodejs application"

  domains = [
    "example.com",
    "sub.example.com",
  ]

  environment = {
    key    = "key"
    value  = "value"
    secure = false
  }

  app_source = {
    type     = "git"
    revision = "master"
    url      = "https://github.com/awslabs/opsworks-windows-demo-nodejs.git"
  }

  /*enable_ssl = true

  ssl_configuration = {
    private_key = "${file("./foobar.key")}"
    certificate = "${file("./foobar.crt")}"
  }*/

}

# opsworks instance for pocapp

resource "aws_opsworks_instance" "pocapp-instance" {
  stack_id = "${aws_opsworks_stack.pocapp_stack.id}"

  layer_ids = [
    "${aws_opsworks_nodejs_app_layer.pocapp.id}",
  ]

  availability_zone = "us-east-1b"
  instance_type = "m1.small"
  subnet_id = "subnet-8f511bd4"
  #os            = "Ubuntu 14.04 LTS"
  state         = "stopped"
}


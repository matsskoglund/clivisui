provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "clivisui-load_balancers" {
  name        = "clivisui-load_balancers"
  description = "Allows all traffic"

  vpc_id = "${var.clivis_vpc}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TODO: this probably only needs egress to the ECS security group.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "clivisui-sg" {
  name        = "clivisui-sg"
  description = "Allows all traffic"

  vpc_id = "${var.clivis_vpc}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.clivisui-load_balancers.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "clivisui-ecs" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_autoscaling_group" "clivisui-asg" {
  # availability_zones   = ["${var.availability_zone1}", "${var.availability_zone2}"]
  name                 = "${var.ecs_cluster_name}-asg"
  min_size             = "${var.autoscale_min}"
  max_size             = "${var.autoscale_max}"
  desired_capacity     = "${var.autoscale_desired}"
  health_check_type    = "EC2"
  launch_configuration = "${aws_launch_configuration.clivisui-lc.name}"

  vpc_zone_identifier = ["${aws_subnet.clivisui_subnet1.id}", "${aws_subnet.clivisui_subnet2.id}"]
}

resource "aws_launch_configuration" "clivisui-lc" {
  #name                 = "${var.ecs_cluster_name}-lc"
  image_id             = "${lookup(var.amis, var.region)}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.clivisui-sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.clivisui_ip.name}"

  associate_public_ip_address = true
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "clivisui_ecs_host_role" {
  name               = "clivisui_ecs_host_role"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name   = "ecs_instance_role_policy"
  policy = "${file("policies/ecs-instance-role-policy.json")}"
  role   = "${aws_iam_role.clivisui_ecs_host_role.id}"
}

resource "aws_iam_role" "clivisui_ecs_service_role" {
  name               = "clivisui_ecs_service_role"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs_service_role_policy"
  policy = "${file("policies/ecs-service-role-policy.json")}"
  role   = "${aws_iam_role.clivisui_ecs_service_role.id}"
}

resource "aws_iam_instance_profile" "clivisui_ip" {
  name  = "clivisui_instance_profile"
  path  = "/"
  roles = ["${aws_iam_role.clivisui_ecs_host_role.name}"]
}

resource "aws_iam_role_policy" "ecr_container_policy" {
  name   = "ecr_container_policy"
  policy = "${file("policies/ecr-role-policy.json")}"
  role   = "${aws_iam_role.clivisui_ecs_host_role.id}"
}

resource "aws_iam_role_policy" "log_policy" {
  name   = "log_policy"
  policy = "${file("policies/log-policy.json")}"
  role   = "${aws_iam_role.clivisui_ecs_host_role.id}"
}

resource "aws_cloudwatch_log_group" "clivisui-lg" {
  name              = "clivisui-lg"
  retention_in_days = "7"

  tags {
    Environment = "experimentation"
    Application = "clivisui"
  }
}

#resource "aws_cloudwatch_log_stream" "clivisui-log-stream" {
# name           = "clivisui-log-stream"
# log_group_name = "${aws_cloudwatch_log_group.clivisui-lg.name}"
#}

data "template_file" "clivisui-task-template" {
  template = "${file("task-definitions/clivisui-task-template.json.tpl")}"

  vars {
    image_id        = "${var.image_id}"
    env_service_url = "${var.service_url}"
    log-group       = "${aws_cloudwatch_log_group.clivisui-lg.name}"

    #log-stream      = "${aws_cloudwatch_log_stream.clivisui-log-stream.name}"
  }
}

resource "aws_alb_target_group" "clivisui-tg" {
  name     = "clivisui-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.clivis_vpc}"

  health_check {
    path     = "/Home/Ping"
    timeout  = "5"
    interval = "120"
    matcher  = "200,204"
  }
}

resource "aws_alb" "clivisui-alb" {
  name            = "clivisui-alb"
  security_groups = ["${aws_security_group.clivisui-load_balancers.id}"]
  subnets         = ["${aws_subnet.clivisui_subnet1.id}", "${aws_subnet.clivisui_subnet2.id}"]
}

resource "aws_alb_listener" "clivisui-al" {
  load_balancer_arn = "${aws_alb.clivisui-alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.clivisui-tg.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "clivisui-als" {
  load_balancer_arn = "${aws_alb.clivisui-alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "arn:aws:acm:eu-west-1:644569545355:certificate/bfba317a-77f1-407b-acdd-a12302234a33"

  default_action {
    target_group_arn = "${aws_alb_target_group.clivisui-tg.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "clivisui-lr" {
  listener_arn = "${aws_alb_listener.clivisui-al.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.clivisui-tg.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}

resource "aws_ecs_task_definition" "clivisui-td" {
  family                = "clivisui"
  container_definitions = "${data.template_file.clivisui-task-template.rendered}"
}

resource "aws_ecs_service" "clivisui-service" {
  name            = "clivisui-service"
  cluster         = "${aws_ecs_cluster.clivisui-ecs.id}"
  task_definition = "${aws_ecs_task_definition.clivisui-td.arn}"
  iam_role        = "${aws_iam_role.clivisui_ecs_service_role.arn}"
  desired_count   = 2

  depends_on = ["aws_iam_role_policy.ecs_service_role_policy",
    "aws_alb_listener.clivisui-al",
  ]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.clivisui-tg.arn}"
    container_name   = "clivisui"
    container_port   = 80
  }
}

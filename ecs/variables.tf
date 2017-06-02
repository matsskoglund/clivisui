variable "aws_access_key" {
  description = "The AWS access key."
}

variable "aws_secret_key" {
  description = "The AWS secret key."
}

variable "key_name" {
  description = "name of the ssh key"
  default     = "mskvb0-key"
}

variable "clivis_vpc" {
  default = "vpc-ef272e8b"
}

variable "clivis_gw" {
  default = "igw-b411a9d0"
}

#variable "public_subnet_id1" {
#  default = "subnet-6bcada0f"
#}

#variable "public_subnet_id2" {
#  default = "subnet-818091f7"
#}
resource "aws_subnet" "clivisui_subnet1" {
  vpc_id                  = "${var.clivis_vpc}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1c"
  map_public_ip_on_launch = true

  tags {
    Name = "clivisui_subnet1"
  }
}

resource "aws_subnet" "clivisui_subnet2" {
  vpc_id                  = "${var.clivis_vpc}"
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags {
    Name = "clivisui_subnet2"
  }
}

resource "aws_route_table" "clivisui-eu-west-public" {
  vpc_id = "${var.clivis_vpc}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.clivis_gw}"
  }

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "clivisui-eu-west-1c-public" {
  subnet_id      = "${aws_subnet.clivisui_subnet1.id}"
  route_table_id = "${aws_route_table.clivisui-eu-west-public.id}"
}

resource "aws_route_table_association" "clivisui-eu-west-1a-public" {
  subnet_id      = "${aws_subnet.clivisui_subnet2.id}"
  route_table_id = "${aws_route_table.clivisui-eu-west-public.id}"
}

variable "region" {
  default = "eu-west-1"
}

# TODO: support multiple availability zones, and default to it.
variable "availability_zone1" {
  description = "The availability zone 1"
  default     = "eu-west-1a"
}

variable "availability_zone2" {
  description = "The availability zone 2"
  default     = "eu-west-1c"
}

variable "ecs_cluster_name" {
  description = "The name of the Amazon ECS cluster."
  default     = "clivisui-ecs-cluster"
}

variable "amis" {
  description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."

  default = {
    eu-west-1 = "ami-a7f2acc1"
  }
}

variable "autoscale_min" {
  default     = "1"
  description = "Minimum autoscale (number of EC2)"
}

variable "autoscale_max" {
  default     = "4"
  description = "Maximum autoscale (number of EC2)"
}

variable "autoscale_desired" {
  default     = "2"
  description = "Desired autoscale (number of EC2)"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "image_id" {
  description = "The docker image id to use"
  default     = "latest"
}

variable "service_url" {
  description = "The Service URL"
  default     = "http://clivis.abolint.se:5050"
}

output "alb-dns-name" {
  value = "${aws_alb.clivisui-alb.dns_name}"
}

#resource "aws_internet_gateway" "clivisui-gw" {
#  vpc_id = "${var.clivis_vpc}"


#  tags {
#    Name = "clivis-gw"
#  }
#}


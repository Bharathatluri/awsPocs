provider "aws" {
  region  = "us-east-1"
}

resource "aws_vpc" "A4LVPC" {

  cidr_block = "10.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  

  tags = {
    key = "name"
    value = "A4LVPC"
  }
}

resource "aws_internet_gateway" "A4L-IGW" {
  vpc_id = aws_vpc.A4LVPC.id
  
  tags = {
    Name = "A4L-IGW"
  }
}

resource "aws_route_table" "RTPub" {
  vpc_id = aws_vpc.A4LVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.A4L-IGW.id
  }


  tags = {
    Name = "A4L-vpc-rt-pub"
  }

}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.SNPUBA.id
  route_table_id = aws_route_table.RTPub.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.SNPUBB.id
  route_table_id = aws_route_table.RTPub.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.SNPUBB.id
  route_table_id = aws_route_table.RTPub.id
}


resource "aws_subnet" "SNDBA" {
  vpc_id     = aws_vpc.A4LVPC.id
  cidr_block = "10.16.16.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-db-A"
  }
}


resource "aws_subnet" "SNDBB" {
  vpc_id     = aws_vpc.A4LVPC.id
  cidr_block = "10.16.80.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "sn-db-B"
  }
}

resource "aws_subnet" "SNDBC" {
  vpc_id     = aws_vpc.A4LVPC.id
  cidr_block = "10.16.144.0/20"
  availability_zone = "us-east-1c"

  tags = {
    Name = "sn-db-C"
  }
}


resource "aws_subnet" "SNAPPA" {
  vpc_id     = aws_vpc.A4LVPC.id
  cidr_block = "10.16.32.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-app-A"
  }
}


resource "aws_subnet" "SNAPPB" {
  vpc_id     = aws_vpc.A4LVPC.id
  cidr_block = "10.16.96.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "sn-app-B"
  }
}


resource "aws_subnet" "SNAPPC" {
  vpc_id     = aws_vpc.A4LVPC.id
  cidr_block = "10.16.160.0/20"
  availability_zone = "us-east-1c"

  tags = {
    Name = "sn-app-C"
  }
}


resource "aws_subnet" "SNPUBA" {
  vpc_id     = aws_vpc.A4LVPC.id
  cidr_block = "10.16.48.0/20"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "sn-pub-A"
  }
}


resource "aws_subnet" "SNPUBB" {
  vpc_id     = aws_vpc.A4LVPC.id
  cidr_block = "10.16.112.0/20"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "sn-pub-B"
  }
}


resource "aws_subnet" "SNPUBC" {
  vpc_id     = aws_vpc.A4LVPC.id
  cidr_block = "10.16.176.0/20"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "sn-pub-C"
  }
}

resource "aws_security_group" "SGWordpress" {
  name        = "SGWordpress"
  description = "Control access to Wordpress Instance(s)"
  vpc_id      = aws_vpc.A4LVPC.id

  ingress {
    description      = "Allow HTTP IPv4 IN"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SGWordpress"
  }
}

resource "aws_security_group" "SGDatabase" {
  name        = "SGDatabase"
  description = "Control access to Database"
  vpc_id      = aws_vpc.A4LVPC.id

  ingress {
    description      = "Allow MySQL IN"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.SGWordpress.id}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SGDatabase"
  }
}


resource "aws_security_group" "SGLoadBalancer" {
  name        = "SGLoadBalancer"
  description = "Control access to Load Balancer"
  vpc_id      = aws_vpc.A4LVPC.id

  ingress {
    description      = "Allow HTTP IPv4 IN"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SGLoadBalancer"
  }
}


resource "aws_security_group" "SGEFS" {
  name        = "SGEFS"
  description = "Control access to EFS"
  vpc_id      = aws_vpc.A4LVPC.id

  ingress {
    description      = "Allow HTTP IPv4 IN"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.SGWordpress.id}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SGEFS"
  }
}

resource "aws_iam_role" "WordpressRole" {
  name = "WordpressRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  
  path = "/"
}

resource "aws_iam_role_policy_attachment" "mgd_pol_1" {
  role       = "${aws_iam_role.WordpressRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "mgd_pol_2" {
  role       = "${aws_iam_role.WordpressRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
}

resource "aws_iam_instance_profile" "WordpressInstanceProfile" {
  name = "WordpressInstanceProfile"
  role = aws_iam_role.WordpressRole.name
}

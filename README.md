# terraform-3-tier
This is a terraform code to create AWS 3-tier architecture.

Terraform AWS Three Tier Application

Three-Tier Architecture in AWS Using Terraform 

A three-tier architecture is a software architecture pattern where the application is broken down into three logical tiers: the presentation layer, the business logic layer, and the data storage layer. This architecture is used in a client-server application such as a web application that has the frontend, the backend, and the database. Each of these layers or tiers does a specific task and can be managed independently of each other.


AWS :

Amazon Web Service (AWS) is a cloud platform that provides different cloud computing services to its customers. In this article, we shall be making use of the following AWS services to design and build a three-tier cloud infrastructure:
Elastic Compute Cloud (EC2),
Virtual Private Cloud(VPC),
Elastic Load Balancer (ELB),
Security Groups and
Internet Gateway.


Terraform :

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.
The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.


Infrastructure as Code
The future of Ops is code. DevOps is firmly attached to the concept of expressing, versioning, and reusing your infrastructure in the form of programming code.

Let’s Begin With Project :
Steps for our project to complete :

1. Virtual Private Cloud (VPC):
2. Setup the Internet Gateway:
3. Create 3 Subnets :
4. Create Two Route Tables with route table Association:
5. Create the NAT Gateway:
6. Create RDS for storage :

Project Overview :

Step 1: Create our own VPC for our project with a CIDR Range
Step 2: Set Internet Gateway to connect with VPC
Step 3: Create 3 subnet as one as public and 2 private subnets.
Step 4: Set route table with Table Association
Step 5: Create NAT Gateway for private instance to get Internet path from the public to private.
Step 6: Create RDS Storage to store the data of the application into the database. That database is called RDS.

Using a terraform to set three-tier architecture application deployment in AWS step by step process


Set providers :

Our local system has to connect with AWS using some credentials. To connect AWS to the local system.

Log in to AWS :

Using your own credentials and login into your account :

GO TO : IAM >> Users >> Click your username >> Security Credentials >> Create Access Key


Access key automatically generates the Access key and product key for your user account. (Don't share with any social media like git, FB, etc)

And that secret access key is downloaded and save in an excel format for future referral.

Come to the local system which terraforms is already installed.

Create directory :

>> mkdir terraform_aws

>> cd terraform_aws

Create terraform file for access AWS using above secret access keys

Create terraform file :

>>  vi providers.tf

provider "aws" {
  access_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  region     = "ap-southeast-1"
}

(This is the provider's file and we insert access key and secret key to access AWS using terraform)

Afterward, we have to set whats the cloud providers are so we initialize the terraform in this folder.

>> terraform init

(This code is to initialize our terraform file what the providers we have to use. And init command download the needed plugins)

Create VPC:

>> vi vpc.tf

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "new_VPC"
  }
}

(Create our own vpc to deploy our own three tier architecture for aws)

Create internet gateway for our vpc:

>> vi internet.tf

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags {
    Name = "InternetGateway"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

(Create Intenet gateway with VPC. And the internet Access is what the routing table has to access the internet)


Elastic IP :

>> vi eip.tf

resource "aws_eip" "eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]
}

Create Nat :

(create nat for internet access to my private instances)

>> vi nat.tf

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = ["aws_internet_gateway.gw"]
}


Create subnets :

(This for create our public subnets)

>> vi Public.tf

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
  tags = {
    Name = "zippyopspublicsubnet"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags {
    Name = "public_route"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


public subnet:

Create a public subnet with VPC.

Public Route table connects with VPC.

Public route is connected with nat based on Interet Gateway

subnet table Association with public subnet and public route table

(This for create our private subnets)

>> vi private.tf

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "zippyopsprivatesubnet"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags {
    Name = "private_route"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

>> private2.tf

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1c"
  tags = {
    Name = "zippyopsprivatesubnet1"
  }
}

resource "aws_route_table" "private_route_table1" {
  vpc_id = aws_vpc.vpc.id
  tags {
    Name = "private_route1"
  }
}

resource "aws_route_table_association" "private_subnet_association1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table1.id
}


private subnet:

Create a private subnet with VPC.

private Route table connects with VPC.

The private route is connected with nat based on Internet Gateway.

subnet table Association with private subnet and private route table.


Security Group :

Security group is acts as firewall for our instance. Who will access our instance permisssions port assigning, and all ingress and out put function for our instance is defined in security group.

>> sg.tf

resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = "security-group"
  description = "Allow SSH and http and https"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["10.0.2.0/24"]
  }
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

  tags {
    Name = "sg"
  }
}

Create instance:
create a public instance with the security group, key, and instance specification. Because the webserver is in public so we have to configure Nginx for our private instances. Nginx conf file is attached below of these sessions.

>> instance1.tf

resource "aws_instance" "nginx" {
  ami                         = "ami-0b419c3a4b01d1859"
  instance_type               = "t2.micro"
  key_name                    = "zippyops"
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  tags {
    Name = "zippyops-nginx"
  }
}
user_data = <#!/bin/bash
yum update -y
sudo amazon-linux-extras install epel -y
yum update -y
yum install wget -y
yum install nginx -y
yum install git -y
service nginx start
rm -rf /etc/nginx/nginx.conf
cd /etc/nginx/
wget https://raw.githubusercontent.com/Zippyops/phpcodelogin/main/nginx.conf
systemctl restart nginx
HEREDOC
}

Create application Instance :
These Instances for our application server. We can inbuild our application on this server.

>> Instance2.tf

resource "aws_instance" "web" {
  ami                         = "ami-0b419c3a4b01d1859"
  instance_type               = "t2.micro"
  key_name                    = "zippyops"
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  subnet_id                   = aws_subnet.private_subnet.id
  private_ip                  = "10.0.1.11"
  associate_public_ip_address = false
  tags {
    Name = "zippyops-web2"
  }

user_data = <
#!/bin/bash
yum update -y
sudo amazon-linux-extras install epel -y
sudo yum update -y
sudo amazon-linux-extras install -y php7.2
sudo yum install httpd -y
service start httpd
yum install git -y
cd /var/www/html/
git clone https://github.com/Zippyops/phpcodelogin.git
cd phpcodelogin/
mv * /var/www/html/
yum install wget -y
yum install mysql -y
yum install mysql-server -y
service mysqld restart
systemctl restart httpd
cd /var/www/html/

mysql -h wpdb.cdy9kerizbgn.ap-southeast-1.rds.amazonaws.com -u zippyops -pmypassword -D wordpress_db < table.sql

HEREDOC
}

(Here just deploy PHP application with Mysql(rds) And that -h host is an entry point of RDS )

RDS INSTANCE :
Rds instance saves the data of my application and acts as a database server.

>> rds.tf

resource "aws_db_subnet_group" "dbsubnet" {
  name       = "main"
  subnet_ids = ["${aws_subnet.private_subnet1.id}", "${aws_subnet.private_subnet.id}"]
  tags = {
    Name = "My DB subnet group"
  }
}

#provision the database
resource "aws_db_instance" "wpdb" {
  identifier             = "wpdb"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  engine                 = "mysql"
  name                   = "wordpress_db"
  password               = "mypassword"
  username               = "zippyops"
  engine_version         = "5.6.40"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.name
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  # Workaround for Symphony
  lifecycle {
    ignore_changes = ["engine", "auto_minor_version_upgrade", "vpc_security_group_ids"]
  }
}


resource "aws_security_group" "db" {
  name   = "db-secgroup"
  vpc_id = aws_vpc.vpc.id

  # ssh access from anywhere
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


All the terraform code is set now and activate our code.
>>terraform plan

This is for the plan of our terraform code
>> terraform apply

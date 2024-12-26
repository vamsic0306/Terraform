provider "aws" {
  region = "us-east-1"
}
resource "aws_db_instance" "dev" {
    engine = "mysql"                    # Database engine
    engine_version = "8.0.39"           # Engine version
    allocated_storage = 20              # By default you will get 20gb if you are using free tier
    instance_class = "db.t3.micro"      # Define your instance class type
    identifier = "mydb"                 # Name of your database
    username = "admin"                  # Master username
    password = "dilip123"               # Never start with @ and keep secure
    publicly_accessible = true          # By default it is false
    final_snapshot_identifier = true    # By default it is false
    tags = {
      Name = "MYRDS"
    }
  
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg-"

  ingress {
    from_port   = 3306                   # MySQL port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]        # Replace with your CIDR block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#This resource creates a Subnet Group for the RDS instance. A Subnet Group is a collection of subnets that AWS RDS uses to place your database within a VPC
resource "aws_db_subnet_group" "default" {
  name       = "my-db-subnet-group"        # Name of the Subnet Group
  subnet_ids = aws_subnet.rds_subnet[*].id # List of subnet IDs created and Replace with your subnet IDs
                                           # The [ * ] syntax fetches all subnet IDs created by the aws_subnet.rds_subnet resource

  tags = {
    Name = "MyDBSubnetGroup"
  }
}

resource "aws_subnet" "rds_subnet" {
  count = 2
  cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index)
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "RDSSubnet-${count.index}"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MyVPC"
  }
}

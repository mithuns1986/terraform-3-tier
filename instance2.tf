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

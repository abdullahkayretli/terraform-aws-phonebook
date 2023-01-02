#! /bin/bash
yum update -y
yum install python3 -y
pip3 install flask
pip3 install flask_mysql
yum install git -y
TOKEN="Your_GitHub_Token"
cd /home/ec2-user && git clone https://$TOKEN@github.com/your_github_username/phonebook.git
python3 /home/ec2-user/phonebook/phonebook-app.py
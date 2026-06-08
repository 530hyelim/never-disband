#!/bin/bash
cd /home/ubuntu/never-disband
git pull origin main
mvn clean package -DskipTests
sudo systemctl stop tomcat
sudo cp target/ROOT.war /opt/tomcat/webapps/ROOT.war
sudo rm -rf /opt/tomcat/webapps/ROOT
sudo systemctl start tomcat
echo "배포 완료!"

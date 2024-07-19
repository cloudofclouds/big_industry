#!/bin/bash

# Ensure script is run as root or with sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update and upgrade the system
apt-get update -y
apt-get upgrade -y

# Install Java (adjust version as needed)
apt-get install -y openjdk-11-jdk

# Install Git
apt-get install -y git

# Install Jenkins agent dependencies (e.g., Python, Docker, etc.)
apt-get install -y python3-pip docker.io

# Install Jenkins agent package (adjust version as needed)
wget -O /tmp/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/4.11/remoting-4.11.jar
mkdir -p /opt/jenkins
mv /tmp/agent.jar /opt/jenkins/agent.jar

# Ensure Jenkins agent directory is writable by Jenkins user
chown -R jenkins:jenkins /opt/jenkins

# Register Jenkins agent with master
# Replace placeholders with actual Jenkins master URL, secret, and agent name
java -jar /opt/jenkins/agent.jar -jnlpUrl http://54.202.83.34:8080/computer/agent-name/slave-agent.jnlp -secret your-secret -workDir "/opt/jenkins" -tunnel 54.202.83.34:8080 -url http://54.202.83.34:8080

# Start Jenkins agent as a service (optional, depending on your setup)
# Example of starting Jenkins agent as a systemd service
cat << EOF > /etc/systemd/system/jenkins-agent.service
[Unit]
Description=Jenkins Agent
After=network.target

[Service]
User=jenkins
ExecStart=/usr/bin/java -jar /opt/jenkins/agent.jar -jnlpUrl http://54.202.83.34:8080/computer/agent-name/slave-agent.jnlp -secret your-secret -workDir "/opt/jenkins" -retry 5 -tunnel 54.202.83.34:8080 -url http://54.202.83.34:8080
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable jenkins-agent
systemctl start jenkins-agent

# Print completion message
echo "Jenkins agent configuration complete."

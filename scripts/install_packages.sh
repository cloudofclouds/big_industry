#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Java 17
sudo apt-get install -y openjdk-17-jdk

# Install Maven
sudo apt-get install -y maven

# Install Git
sudo apt-get install -y git

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update -y
sudo apt-get install -y jenkins

# Download Jenkins WAR file manually
sudo mkdir -p /usr/share/jenkins
wget -O /usr/share/jenkins/jenkins.war http://updates.jenkins-ci.org/latest/jenkins.war
sudo chown -R jenkins:jenkins /usr/share/jenkins

# Ensure Jenkins home directory is set correctly
sudo mkdir -p /var/lib/jenkins
sudo chown -R jenkins:jenkins /var/lib/jenkins

# Create Jenkins systemd service file if it doesn't exist
if [ ! -f /etc/systemd/system/jenkins.service ]; then
    cat <<EOL | sudo tee /etc/systemd/system/jenkins.service
[Unit]
Description=Jenkins Continuous Integration Server
Documentation=https://jenkins.io/doc/
After=network.target

[Service]
ExecStart=/usr/bin/java -Djenkins.install.runSetupWizard=false -jar /usr/share/jenkins/jenkins.war
User=jenkins
Restart=on-failure
Environment="JENKINS_HOME=/var/lib/jenkins"

[Install]
WantedBy=multi-user.target
EOL
fi

# Reload the systemd daemon to recognize the Jenkins service
sudo systemctl daemon-reload

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Docker
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce
sudo usermod -aG docker $USER
newgrp docker

# Install Ansible
sudo apt-get install -y ansible

# Install Kubernetes (kubectl)
sudo apt-get update -y && sudo apt-get install -y apt-transport-https gnupg2 curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubectl

# Install Prometheus
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.29.1/prometheus-2.29.1.linux-amd64.tar.gz
tar -xvf prometheus-2.29.1.linux-amd64.tar.gz
cd prometheus-2.29.1.linux-amd64
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo cp prometheus.yml /etc/prometheus/prometheus.yml

# Create Prometheus systemd service file
if [ ! -f /etc/systemd/system/prometheus.service ]; then
    cat <<EOL | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/

[Install]
WantedBy=default.target
EOL
fi

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Install Grafana
# sudo apt-get install -y software-properties-common
# wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
# echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
# sudo apt-get update -y
# sudo apt-get install -y grafana
# sudo systemctl start grafana-server
# sudo systemctl enable grafana-server

# Print completion message
echo "All tools have been installed and started successfully."
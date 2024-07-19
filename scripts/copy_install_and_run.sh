IP=$1
# Transfer the script to the remote server
scp install_packages.sh ubuntu@${IP}:~/install_packages.sh

# Execute the script on the remote server
ssh ubuntu@${IP} 'chmod +x install_packages.sh &&  ./install_packages.sh'

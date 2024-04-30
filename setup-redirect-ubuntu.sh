#!/bin/bash
# on Ubuntu
# resume: 
# 1 - check if is using sudo
# 2 - install nvm
# 3 - apt update
# 4 - install nginx
# 5 - setup firewall
# 6 - use certbot
# 7 - config nginx to redirect traffic

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root"
  exit 1
fi

# installs NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install --lts
node -v
npm -v 
echo "Node.js and npm installation completed successfully"

sudo apt update

# https://www.theknowledgeacademy.com/blog/how-to-install-nginx-on-ubuntu-20-04/
# Install NGINX Open Source:
sudo apt install nginx 
nginx -v 
sudo systemctl enable nginx 
sudo systemctl restart nginx 

# echo "Setup firewall - ufw does not work"
echo "Setup firewall"
sudo apt install firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --state
sudo firewall-cmd --zone=public --add-port=3000/tcp --permanent
sudo firewall-cmd --zone=public --add-service=ssh --permanent
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --zone=public --add-service=https --permanent
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo firewall-cmd --reload
echo "Successfully setup firewall"

# use certbot
sudo apt-get remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
# sudo certbot certonly --standalone -d # optional
sudo certbot --nginx -d # < domain >

# to generate for wildcard:
# https://computingforgeeks.com/using-letsencrypt-wildcard-certificate-nginx-apache/

# to redirect traffic from a domain/name server to a localhost port, update the default config file inside /etc/nginx/sites-available.
# for each server block, update the location block
# location / {
#     proxy_pass http://localhost:3000;
#     proxy_set_header Host $host;
#     proxy_set_header X-Real-IP $remote_addr;
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#     proxy_set_header X-Forwarded-Proto $scheme;
#     proxy_redirect off;
# }
#
# also check if the allowPortForwarding parameter is enabled in ssh config file

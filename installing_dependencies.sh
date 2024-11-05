#!/bin/bash

exec > >(tee -i setup.log)  # Redirect stdout to setup.log
exec 2>&1                   # Redirect stderr to stdout
echo "Starting setup at $(date)"


# Update the package list and upgrade installed packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Unzip to extract web application files
sudo apt-get install -y unzip

# Install Node.js and NPM
# Note: Use NodeSource for specific Node.js versions if needed.
# curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
# sudo apt-get install -y nodejs
#
sudo apt-get install -y nodejs npm

# Install MySQL server
sudo apt-get install mysql-server -y

# Start the MySQL service and enable it to start on boot
sudo systemctl start mysql
sudo systemctl enable mysql

# Create a MySQL user 'keshni21' with password 'keshni' and grant privileges
# Change 'keshni' to a more secure password in production
sudo mysql -u root -e "CREATE USER 'keshni21'@'localhost' IDENTIFIED BY 'keshni21';"
sudo mysql -u root -e "CREATE DATABASE database_cloud;"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON database_cloud.* TO 'keshni21'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# Unzip the webapp.zip file to /home/ubuntu/webapp
if unzip ~/webapp.zip -d /home/ubuntu/webapp; then
    echo "Unzipped webapp.zip successfully."
else
    echo "Failed to unzip webapp.zip. Exiting."
    exit 1
fi

# Navigate to the application folder
cd /home/ubuntu/webapp || { echo "Failed to navigate to webapp directory"; exit 1; }

# Install the npm dependencies for the Node.js application
npm install

sudo bash -c 'cat > /home/ubuntu/webapp/.env <<EOF
devUsername =  keshni21    
devPassword =  Keshni@2198
devDB = database_cloud       
devHost =localhost                     


PORT=8080                             


EOF'


# Create a systemd service file for the Node.js application
sudo bash -c 'cat > /etc/systemd/system/nodeapp.service <<EOF
[Unit]
Description=Node.js Application
After=network.target

[Service]
ExecStart=/usr/bin/node /home/ubuntu/webapp/app.js
Restart=always
User=ubuntu
Group=ubuntu
Environment=PATH=/usr/bin:/usr/local/bin
Environment=NODE_ENV=production
WorkingDirectory=/home/ubuntu/webapp

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd to recognize the new service and enable it to start on boot
sudo systemctl daemon-reload
sudo systemctl enable nodeapp  # Enable the Node.js app service to start on boot
sudo systemctl start nodeapp    # Start the Node.js app immediately

# Output the status of the Node.js application service
sudo systemctl status nodeapp

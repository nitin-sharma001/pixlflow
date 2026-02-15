#!/bin/bash

# Exit on error
set -e

echo "Starting PixlFlow Setup..."

# 1. Update system packages
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# 2. Install Node.js (20.x LTS)
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node -v
npm -v

# 3. Install PM2 (Process Manager)
echo "Installing PM2..."
sudo npm install -g pm2

# 4. Install Project Dependencies
if [ -f "package.json" ]; then
    echo "Installing project dependencies..."
    npm install
else
    echo "No package.json found. Skipping npm install."
fi

# 5. Start the Application
echo "Starting application with PM2..."
# Check if already running and delete if so
pm2 delete pixlflow 2>/dev/null || true
pm2 start server.js --name "pixlflow"

# 6. Setup PM2 startup hook
echo "Setting up PM2 startup hook..."
# This attempts to automatically setup the startup script. 
# If it fails, it will print instructions.
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu || echo "Please run 'pm2 startup' manually if this step failed."

pm2 save

echo "------------------------------------------------"
echo "Setup Complete!"
echo "Your app should be running on port 8080."
echo "Ensure your EC2 Security Group allows inbound traffic on port 8080."
echo "If you want to run on port 80, you might need to update server.js or use Nginx revers proxy."
echo "------------------------------------------------"

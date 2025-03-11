#!/bin/bash
# @Author Sergey Durmanov
# @Version 2025-03-11

# Function to show progress
show_progress() {
    echo "➜ $1"
}

# Download setting files
echo "Downloading setting files..."
wget -q https://raw.githubusercontent.com/TimewebTutorials/supabase-install/refs/heads/main/.env -O ./docker/.env
wget -q https://raw.githubusercontent.com/TimewebTutorials/supabase-install/refs/heads/main/docker-compose.yml -O ./docker/docker-compose.yml

# Collect input values
echo "Please enter the following configuration values:"
read -p "Enter JWT_SECRET: " INPUT_JWT_SECRET
read -p "Enter ANON_KEY: " INPUT_ANON_KEY
read -p "Enter SERVICE_ROLE_KEY: " INPUT_SERVICE_ROLE_KEY
read -p "Enter POSTGRES_PASSWORD: " INPUT_POSTGRES_PASSWORD
read -p "Enter DASHBOARD_PASSWORD: " INPUT_DASHBOARD_PASSWORD
read -p "Enter your VPS IP (e.g., 111.222.333.444): " INPUT_IP_YOUR_VPS

# Ensure the .env file exists
if [ ! -f ./docker/.env ]; then
    touch ./docker/.env
fi

# Function to update or append a variable in .env
update_env_var() {
    local key=$1
    local value=$2
    if grep -q "^$key=" ./docker/.env; then
        sed -i "s|^$key=.*|$key=$value|" ./docker/.env
    else
        echo "$key=$value" >> ./docker/.env
    fi
}

# Updating values in .env
show_progress "Updating environment variables..."
update_env_var "POSTGRES_PASSWORD" "$INPUT_POSTGRES_PASSWORD"
update_env_var "DASHBOARD_PASSWORD" "$INPUT_DASHBOARD_PASSWORD"
update_env_var "VAULT_ENC_KEY" "none"
update_env_var "SECRET_KEY_BASE" "$INPUT_JWT_SECRET"
update_env_var "SITE_URL" "http://$INPUT_IP_YOUR_VPS:3000"
update_env_var "API_EXTERNAL_URL" "http://$INPUT_IP_YOUR_VPS:8000"
update_env_var "SUPABASE_PUBLIC_URL" "http://$INPUT_IP_YOUR_VPS:8000"
update_env_var "ANON_KEY" "$INPUT_ANON_KEY"
update_env_var "JWT_SECRET" "$INPUT_JWT_SECRET"
update_env_var "SERVICE_ROLE_KEY" "$INPUT_SERVICE_ROLE_KEY"
update_env_var "ENABLE_EMAIL_SIGNUP" "false"

# Updating IP addresses in configuration files
show_progress "Updating IP addresses in configuration files..."
sed -i -E "s/111.111.111.111/$INPUT_IP_YOUR_VPS/g" ./docker/docker-compose.yml
sed -i -E "s/111.111.111.111/$INPUT_IP_YOUR_VPS/g" ./docker/.env

# Updating boolean format in docker-compose.yml
show_progress "Updating boolean format in docker-compose.yml..."
sed -i -E 's/(: *)true/\1"true"/g' ./docker/docker-compose.yml

echo "✅ Configuration update completed successfully!"

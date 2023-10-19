#!/bin/bash

# Exit if any command fails
set -e

# Function to check if a command exists
command_exists () {
  type "$1" &> /dev/null ;
}

# Check for tfenv, install it if not present
if ! command_exists tfenv ; then
  echo "tfenv not found, installing now via Git..."
  if command_exists git ; then
    # Clone the tfenv repository into the ~/.tfenv directory
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv

    # Add tfenv to your PATH for the current session
    export PATH="$HOME/.tfenv/bin:$PATH"

    # Optionally, add tfenv to your PATH permanently by appending the PATH modification
    # to your shell's profile script (e.g., ~/.bashrc, ~/.bash_profile, ~/.zshrc)
    echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile # or ~/.bashrc or ~/.zshrc
  else
    echo "Error: git is required to install tfenv." >&2
    exit 1
  fi
fi

# Check if SSH keys exist, generate them if not
KEY_DIR="./ssh_keys"
KEY_NAME="deployer-key"
mkdir -p $KEY_DIR
if [ ! -f "${KEY_DIR}/${KEY_NAME}.pub" ]; then
  echo "SSH key not found, generating new key..."
  ssh-keygen -t rsa -b 2048 -f "${KEY_DIR}/${KEY_NAME}" -N ""
fi

# Initialize Terraform. If your configuration is already initialized, 
# this won't do anything, but it's good to ensure your configuration is ready to apply.
terraform init

# Capture the current IAM username from AWS
IAM_USER=$(aws iam get-user --query 'User.UserName' --output text)

# Create a Terraform plan with the captured IAM username
terraform plan -out=tfplan -var "iam_user=${IAM_USER}"

# Apply the Terraform plan
terraform apply "tfplan"

# Clean up the plan file after apply
rm -f "tfplan"

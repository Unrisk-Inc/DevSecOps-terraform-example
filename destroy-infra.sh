#!/bin/bash
# Capture the current IAM username from AWS
IAM_USER=$(aws iam get-user --query 'User.UserName' --output text)

# Create a Terraform plan with the captured IAM username
terraform destroy -var "iam_user=${IAM_USER}" -auto-approve

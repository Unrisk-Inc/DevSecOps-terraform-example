# Terraform AWS Lab Example

This repository contains a set of scripts and Terraform configuration files to automate the provisioning and management of AWS resources, including IAM users and EC2 instances.

## Prerequisites

- AWS CLI installed and configured with necessary credentials.
- Terraform installed. Alternatively, the `run-terraform.sh` script will install `tfenv` which can be used to manage Terraform versions.
- `jq` command-line JSON processor installed (required for `create_iam_users.sh`).

## Files Included

- `create_ec2.tf`: Terraform configuration file for provisioning AWS resources.
- `create_iam_users.sh`: Script to automate the creation of AWS IAM users and generate access keys.
- `delete_iam_users.sh`: Script to automate the deletion of AWS IAM users based on a CSV file.
- `run-terraform.sh`: Script to automate Terraform initialization and execution.
- `destroy-infra.sh`: Script to automate Terraform destroy to remove infrastructure.

## Lab Usage

1. **Configure AWS credentials**:
    - Run `aws configure` to configure your AWS credentials.
    - Please make sure to select `us-west-2` as your default region.

2. **Setting Up Terraform**:
    - Run `./run-terraform.sh` to ensure Terraform is initialized and SSH keys are generated.

3. **Connect to created EC2 instance**:
    - Run `ssh -i ./ssh_keys/deployer-key ec2-user@<EC2_PRIVATE_IP>` to connect to the created EC2 instance.

3. **Deleting Terraform Infrastructure**:
    - Run `./destroy-infra.sh` to destroy the created infrastructure.

## Notes
Ensure that your AWS CLI is configured with the necessary credentials and default region before running the scripts or Terraform commands.
The scripts and Terraform configurations are examples and may need to be adjusted to fit your specific use case.

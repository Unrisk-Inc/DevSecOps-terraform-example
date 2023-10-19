#!/bin/bash

# Check if the required CSV file path and Policy ARN are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <PATH_TO_CSV> <POLICY_ARN>"
    exit 1
fi

CSV_FILE=$1
POLICY_ARN=$2

# Function to check if an AWS IAM access key is deleted
check_access_key_deleted() {
    local username=$1
    local access_key=$2

    while true; do
        # Retrieve the status of the access key
        local status=$(aws iam list-access-keys --user-name "$username" --query "AccessKeyMetadata[?AccessKeyId=='$access_key'].Status" --output text)

        # Check if the access key is deleted
        if [ "$status" == "Inactive" ] || [ -z "$status" ]; then
            echo "Access key $access_key for user $username is deleted."
            break
        else
            echo "Waiting for access key $access_key for user $username to be deleted..."
            sleep 5
        fi
    done
}

# Function to check if an AWS IAM user policy is detached
check_policy_detached() {
    local username=$1

    while true; do
        # Retrieve the attached policies for the user
        local policies=$(aws iam list-attached-user-policies --user-name "$username" --query "AttachedPolicies[].PolicyArn" --output text)

        # Check if the policy is detached
        if [[ -z "$policies" ]] || [[ "$policies" != *"$POLICY_ARN"* ]]; then
            echo "Policy $POLICY_ARN is detached from user $username."
            break
        else
            echo "Waiting for policy $POLICY_ARN to be detached from user $username..."
            sleep 5
        fi
    done
}

# Function to delete users from the CSV
delete_users() {
    while IFS=, read -r username access_key secret_key; do
        # Skip the header row
        if [ "$username" != "UserName" ]; then
            echo "Deleting user $username..."

            # Delete the access key associated with the user
            aws iam delete-access-key --user-name "$username" --access-key-id "$access_key"
            check_access_key_deleted "$username" "$access_key"

            # Detach the policy from the user
            echo "Detaching policy $POLICY_ARN from user $username..."
            aws iam detach-user-policy --user-name "$username" --policy-arn "$POLICY_ARN"
            check_policy_detached "$username"

            # Delete the user
            aws iam delete-user --user-name "$username"
        fi
    done < $1
}

# Calling the function with the CSV file path
delete_users $CSV_FILE

# ./delete_iam_users.sh iam_users.csv arn:aws:iam::259411398249:policy/DevSecOpspolicy
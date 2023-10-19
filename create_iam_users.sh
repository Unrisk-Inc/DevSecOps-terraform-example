#!/bin/bash

# Function to check if 'jq' is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo "Error: jq could not be found."
        echo "Please install jq before running this script."
        exit 1
    fi
}

# Check if the required number of users to be created was passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <NUM_OF_USERS> <POLICY_ARN>"
    exit 1
fi

NUM_OF_USERS=$1
POLICY_ARN=$2
OUTPUT_FILE="iam_users.csv"

# Header for the CSV file
echo "UserName,AccessKey,SecretKey" > $OUTPUT_FILE

for ((i = 1; i <= NUM_OF_USERS; i++)); do
    # Generate a random username for the IAM user
    USER_NAME="user_$((RANDOM % 9999))_$(date +%s)"

    # Create a new IAM user
    aws iam create-user --user-name $USER_NAME

    # Attach the policy to the user
    aws iam attach-user-policy --user-name $USER_NAME --policy-arn $POLICY_ARN

    # Create access key for the new user and save the output to a variable
    RESULT=$(aws iam create-access-key --user-name $USER_NAME)

    # Use 'jq' to parse the JSON output for 'AccessKeyId' and 'SecretAccessKey'
    ACCESS_KEY=$(echo $RESULT | jq -r '.AccessKey.AccessKeyId')
    SECRET_KEY=$(echo $RESULT | jq -r '.AccessKey.SecretAccessKey')

    # Append the information to the CSV file
    echo "$USER_NAME,$ACCESS_KEY,$SECRET_KEY" >> $OUTPUT_FILE
done

echo "Generated $OUTPUT_FILE with $NUM_OF_USERS users."

#
## ./create_iam_users.sh 5 arn:aws:iam::259411398249:policy/DevSecOpspolicy
#


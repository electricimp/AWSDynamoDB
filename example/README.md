# Demo Instructions

This example shows who to create a DynamoDB table and then perform actions on
data within the table, all from agent code using this library.

This example assumes you are familiar with impCentral, and have already configured a device group to run the example code.

The sample code requires AWS keys. The instructions below will guide you how to set up the keys. These keys will need to be entered into the example code.

## Setting up IAM Policy

An IAM policy defines certain permissions within AWS. You will need to create
one that covers all of the DynamoDB actions you want to perform.

1. Login to the [AWS console](https://aws.amazon.com/console/)
1. Select `Services` link (on the top left of the page) and them type `IAM` in the search line
1. Select `IAM Manage User Access and Encryption Keys` item
1. Select `Policies` item from the menu on the left
1. Press `Create Policy`
1. On the `Create Policy` page do the following
    1. Click `Service` or `Choose a service` locate and select `DynamoDB`
    1. Click `Actions` under `Manual Actions` Check `All DynamoDB actions(dynamodb:*)` (this will create 4 warnings)
    1. Click `Resources` and select `All resources` (this should resolve the warnings)
    1. Press `Review plicy` button
    1. Give your policy a name, for example, `allow-DynamoDB`
    1. Press `Create Policy`

## Setting up the IAM User

An IAM user identifies a user, device, application, etc. that performs actions
on or uses AWS resources. You will need to create a user that will identify
your Electric Imp devices and attach the IAM policy to that user.

1. Select `Services` link (on the top left of the page) and them type `IAM` in the search line
1. Select the `IAM Manage User Access and Encryption Keys` item
1. Select `Users` item from the menu on the left
1. Press `Add user`
1. Choose a user name, for example `user-calling-DynamoDB`
1. Check `Programmatic access` but not anything else
1. Press `Next: Permissions` button
1. Press `Attach existing policies directly` icon
1. Check the name of the policy you just created (for example: `allow-DynamoDB`) from the list of policies
1. Press `Next: Review`
1. Press `Create user`
1. Copy down your `Access key ID` and `Secret access key`, these will need to be entered into the agent code

## Setting up Agent Code

Copy and paste the [code](sample.agent.nut) into the agent.

Find the code comment `Enter Your AWS details here` and locate the following constants.

| Constant                     | Description           |
| ---------------------------- | --------------------- |
| AWS_DYNAMO_ACCESS_KEY_ID     | IAM Access Key ID     |
| AWS_DYNAMO_SECRET_ACCESS_KEY | IAM Secret Access Key |
| AWS_DYNAMO_REGION            | AWS region            |

Enter the `Access key ID` and `Secret access key` from the previous step into the corresponding constants.

AWSRequestV4 library requires a region, so you will need to choose an AWS region (for example `us-west-2`) to enter into the `AWS_DYNAMO_REGION` constant. See [AWS docs](https://docs.aws.amazon.com/general/latest/gr/rande.html#ddb_region) for a list regions.

Run the example code and it should create a dynamoDB table, put a item in the table and retrieve it. After this the table is deleted.

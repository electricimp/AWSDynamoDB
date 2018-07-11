# Instructions #

This example demonstrates how to create a DynamoDB table and then perform actions on data within the table.

This example assumes you are familiar with impCentral, and have already created a Device Group to run the example code.

The sample code requires AWS keys. The instructions below will help you set up the keys. These keys will need to be entered into the example code.

## Setting Up IAM Policy ##

An IAM policy defines certain permissions within AWS. You will need to create one that covers all of the DynamoDB actions you want to perform.

1. Log in to the [AWS console](https://aws.amazon.com/console/).
1. Select the **Services** link (on the top left of the page) and then type `IAM` into the search field.
1. Select **IAM Manage User Access and Encryption Keys**.
1. Select **Policies** from the menu on the left.
1. Click **Create Policy**.
1. On the **Create Policy** page do the following:
    1. Click **Service** or **Choose a service**, then locate and select **DynamoDB**.
    1. Click **Actions** under **Manual Actions**, then check **All DynamoDB actions(dynamodb:*)** (this will trigger four warnings).
    1. Click **Resources** and select **All resources** (this should resolve the warnings).
    1. Click the **Review policy** button.
    1. Give your policy a name &mdash; for example, `allow-DynamoDB`.
    1. Click **Create Policy**.

## Setting Up The IAM User ##

An IAM user identifies a user, device, application, etc. that performs actions on or uses AWS resources. You will need to create a user that will identify your imp-enabled devices and attach the IAM policy to that user.

1. Select the **Services** link (on the top left of the page) and then type `IAM` in the search field.
1. Select **IAM Manage User Access and Encryption Keys**.
1. Select **Users** from the menu on the left.
1. Click **Add user**.
1. Choose a user name &mdash; for example, `user-calling-DynamoDB`.
1. Check **Programmatic access** but not anything else.
1. Click the **Next: Permissions** button.
1. Click the **Attach existing policies directly** icon.
1. Check the name of the policy you created earlier (eg. `allow-DynamoDB`) from the list of policies.
1. Click the **Next: Review** button.
1. Click **Create user**.
1. Make a note of your **Access key ID** and **Secret access key** &mdash; these will need to be entered into the agent code.

## Setting Up The Agent Code ##

Copy and paste the [code](sample.agent.nut) into the agent.

Find the code comment `// Enter Your AWS details here` and locate the following constants.

| Constant | Description |
| --- | --- |
| AWS_DYNAMO_ACCESS_KEY_ID | IAM Access Key ID |
| AWS_DYNAMO_SECRET_ACCESS_KEY | IAM Secret Access Key |
| AWS_DYNAMO_REGION | AWS region |

Enter the **Access key ID** and **Secret access key** from the previous step into the corresponding constants.

The AWSRequestV4 library requires a region, so you will need to choose an AWS region (for example, `us-west-2`) to enter as the *AWS_DYNAMO_REGION* constant. Please see the [AWS documentation](https://docs.aws.amazon.com/general/latest/gr/rande.html#ddb_region) for a list regions.

Run the example code and it should create a dynamoDB table, put a item into the table, and retrieve it. After this the table is deleted.

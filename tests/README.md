# Test Instructions

The instructions will show you how to set up the tests for AWS DynamoDB.

## Configure the API keys for DynamoDB

Testing requires AWS access keys. For instructions on how to create keys see the README included in the example folder. At the top of the .test.nut files find the three constants that need to be configured and enter your credentials.

**Note:** Once you have added keys to the test code it should be treated carefully, and not checked into version control!

Parameter                    | Description
---------------------------- | -----------
AWS_DYNAMO_REGION            | AWS region (e.g. "us-west-2")
AWS_DYNAMO_ACCESS_KEY_ID     | IAM Access Key ID
AWS_DYNAMO_SECRET_ACCESS_KEY | IAM Secret Access Key

## Imptest

Please update the `.impt.test` file with a deviceGroupId for your account, and make sure you have a device assigned to that device group.
From the command line run `impt test run`.

# License

The AWSDynamoDB library is licensed under the [MIT License](../LICENSE).

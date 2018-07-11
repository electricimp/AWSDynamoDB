# Test Instructions

The instructions will show you how to set up the tests for AWS DynamoDB.

## Configure the API keys for DynamoDB

Testing requires AWS access keys. For instructions on how to create keys, please see the [README file included in the example folder](../example/README.md).

Once keys are created you can store them as environment variables named: *DYNAMO_ACCESS_KEY_ID*, *DYNAMO_SECRET_ACCESS_KEY*, and *DYNAMO_REGION*, or you can copy and paste them into the test code *AWS Key* constants. Please note if you have added keys to the test code it should be treated carefully and **not checked into version control**.

## Imptest

In the `.impt.test` file update the **deviceGroupId** to a device group in your impCentral account, and check that the **agentFile** is set to *AWSDynamoDB.agent.lib.nut*. Make sure all test code includes the *AWSRequestV4 library*.
From the *AWSDynamoDB* directory, log into your account and then enter `impt test run` into the command line.

# License

The AWSDynamoDB library is licensed under the [MIT License](../LICENSE).

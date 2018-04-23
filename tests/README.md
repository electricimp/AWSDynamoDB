# Test Instructions

The instructions will show you how to set up the tests for AWS DynamoDB.

As the sample code includes the private key verbatim in the source, it should be treated carefully, and not checked into version control!

## Configure the API keys for SNS

At the top of the .test.nut files there are three constants that need to be configured.

Parameter                    | Description
---------------------------- | -----------
AWS_DYNAMO_REGION            | AWS region (e.g. "us-west-2")
AWS_DYNAMO_ACCESS_KEY_ID     | IAM Access Key ID
AWS_DYNAMO_SECRET_ACCESS_KEY | IAM Secret Access Key

## Imptest
Please ensure that the `.imptest` agent file includes both AWSRequestV4 library and the AWSDynamoDB class.
From the `tests` directory, run `imptest test`

# License

The AWSDynamoDB library is licensed under the [MIT License](../LICENSE).

# AWSSQS

To add this library to your model, add the following lines to the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSQS.class.nut:1.0.0"
```

**Note: [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be loaded.**

This class can be used to perform actions on the AWS SQS service. E.g. sending messages, receiving messages.

## Class Methods

### constructor(region, accessKeyId, secretAccessKey)

All parameters are strings. Access keys can be generated with IAM.

### DeleteMessage(params, cb)

http://docs.aws.amazon.com/sqs/latest/api/API_DeleteMessage.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### DeleteMessageBatch(params, cb)

http://docs.aws.amazon.com/sqs/latest/api/API_DeleteMessageBatch.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### ReceiveMessageBatch(params, cb)

http://docs.aws.amazon.com/sqs/latest/api/API_ReceiveMessage.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### SendMessage(params, cb)

http://docs.aws.amazon.com/sqs/latest/api/API_SendMessage.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### SendMessageBatch(params, cb)

http://docs.aws.amazon.com/sqs/latest/api/API_SendMessageBatch.html

 Parameter             | Type           | Description
---------------------- | -------------- | -----------
**params** | table     | Table of parameters (See API Reference)
**cb**     | function  | Callback function that takes one parameter (a response table)


## Example

```squirrel
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSQS.class.nut:1.0.0"

const ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const SECRET_ACCESS_KEY = "YOUR_KEY_HERE";

sqs <- AWSSQS("us-west-2", ACCESS_KEY_ID, SECRET_ACCESS_KEY);

// Send Message
sendParams <- {
    "QueueUrl": "YOUR_URL_HERE",
    "MessageBody": "testMessage"
}
sqs.SendMessage(sendParams, function(res) {
    server.log(http.jsonencode(res));
});

// Receive Message
receiveParams <- {
    "QueueUrl": "YOUR_URL_HERE"
}
sqs.ReceiveMessage(receiveParams, function(res) {
    server.log(http.jsonencode(res));
});
```

# License

The AWSSQS library is licensed under the [MIT License](https://github.com/electricimp/thethingsapi/tree/master/LICENSE).

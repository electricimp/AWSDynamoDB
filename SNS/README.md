# AWSSNS

To add this library to your model, add the following lines to the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSNS.class.nut:1.0.0"
```

**Note: [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be loaded.**

This class can be used to perform actions on the AWS SNS service. E.g. subscribing to topics, unsubscribing from topics, publishing messages.

## Class Methods

### constructor(region, accessKeyId, secretAccessKey)

All parameters are strings. Access keys can be generated with IAM.

### ConfirmSubscription(params, cb)

http://docs.aws.amazon.com/sns/latest/api/API_ConfirmSubscription.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### ListSubscriptions(params, cb)

http://docs.aws.amazon.com/sns/latest/api/API_ListSubscriptions.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### ListSubscriptionsByTopic(params, cb)

http://docs.aws.amazon.com/sns/latest/api/API_ListSubscriptionsByTopic.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### ListTopics(params, cb)

http://docs.aws.amazon.com/sns/latest/api/API_ListTopics.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Publish(params, cb)

http://docs.aws.amazon.com/sns/latest/api/API_Publish.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Subscribe(params, cb)

http://docs.aws.amazon.com/sns/latest/api/API_Subscribe.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Unsubscribe(params, cb)

http://docs.aws.amazon.com/sns/latest/api/API_Unsubscribe.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)


## Example

```squirrel
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSNS.class.nut:1.0.0"

const ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const SECRET_ACCESS_KEY = "YOUR_KEY_HERE";

sns <- AWSSNS("us-west-2", ACCESS_KEY_ID, SECRET_ACCESS_KEY);

// Handle incoming HTTP requests
http.onrequest(function(request, response) {

    try {

        local requestBody = http.jsondecode(request.body);

        // Handle an SES SubscriptionConfirmation request
        if ("Type" in requestBody && requestBody.Type == "SubscriptionConfirmation") {
            server.log("Received HTTP Request: AWS_SNS SubscriptionConfirmation");
            local confirmParams = {
                "Token": requestBody.Token,
                "TopicArn": requestBody.TopicArn
            }
            sns.ConfirmSubscription(confirmParams, function(res) {
                server.log("Confirmation Response: " + http.jsonencode(res));
            });
        }

        response.send(200, "OK");

    } catch (exception) {
        server.log("Error handling HTTP request: " + exception);
        response.send(500, "Internal Server Error: " + exception);
    }

})

// Subscribe
subscribeParams <- {
    "Protocol": "https",
    "TopicArn": "YOUR_TOPIC_ARN_HERE",
    "Endpoint": http.agenturl()
}

sns.Subscribe(subscribeParams, function(res) {
    server.log("Subscribe Response: " + http.jsonencode(res));
});
```

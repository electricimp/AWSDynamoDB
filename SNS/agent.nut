//===========================
// Setup
//===========================

#require "PrettyPrinter.class.nut:1.0.1"
#require "AWSRequestV4.class.nut:1.0.2"
#include "AWSSNS.class.nut"

const AWS_REGION = "us-west-2";
const AWS_ACCESS_KEY_ID = "AKIAILHSWHF6ILS72R3A";
const AWS_SECRET_ACCESS_KEY = "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";


//===========================
// Test Code
//===========================

sns <- AWSSNS(AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY);

testTopicArn <- "arn:aws:sns:us-west-2:371007585114:testTopic";

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
    "TopicArn": testTopicArn,
    "Endpoint": http.agenturl()
}

sns.Subscribe(subscribeParams, function(res) {
    server.log("Subscribe Response: " + http.jsonencode(res));
});

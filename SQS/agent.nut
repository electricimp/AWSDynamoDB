//===========================
// Setup
//===========================

#require "PrettyPrinter.class.nut:1.0.1"
#require "AWSRequestV4.class.nut:1.0.2"
#include "AWSSQS.class.nut"

const AWS_REGION = "us-west-2";
const AWS_ACCESS_KEY_ID = "AKIAILHSWHF6ILS72R3A";
const AWS_SECRET_ACCESS_KEY = "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";


//===========================
// Test Code
//===========================

sqs <- AWSSQS(AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY);

// Send Message
/*
sendParams <- {
    "QueueUrl": "https://sqs.us-west-2.amazonaws.com/371007585114/testQueue",
    "MessageBody": "testMessage"
}
sqs.SendMessage(sendParams, function(res) {
    server.log(http.jsonencode(res));
});
*/

// Receive Message
receiveParams <- {
    "QueueUrl": "https://sqs.us-west-2.amazonaws.com/371007585114/testQueue"
}
sqs.ReceiveMessage(receiveParams, function(res) {
    server.log(http.jsonencode(res));
});

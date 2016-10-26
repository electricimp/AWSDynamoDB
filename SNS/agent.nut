//===========================
// Setup
//===========================


const AWS_REGION = "us-west-2";
const AWS_ACCESS_KEY_ID = "AKIAILHSWHF6ILS72R3A";
const AWS_SECRET_ACCESS_KEY = "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";


//===========================
// Test Code
//===========================

sns <- AWSSNS(AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY);

testTopicArn <- "arn:aws:sns:us-west-2:371007585114:testTopic";

// Subscribe
params <- {
    "Protocol": "https",
    "TopicArn": testTopicArn,
    "Endpoint": http.agenturl()
}

sns.Subscribe(params, function(res) {
    server.log(http.jsonencode(res));
    /*
    if ("err" in res) {
        server.log(http.jsonencode(res.err));
    } else {
        server.log(http.jsonencode(res.data));
    }
    */
});

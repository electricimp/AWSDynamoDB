//============================
// Setup
//============================

#require "PrettyPrinter.class.nut:1.0.1"
#require "AWSRequestV4.class.nut:1.0.2"
#include "AWSCloudWatchLogs.class.nut"

// Setup DynamoDB
AWS_REGION     <- "us-west-2";
AWS_ACCESS_KEY <- "AKIAILHSWHF6ILS72R3A";
AWS_SECRET_KEY <- "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";


//============================
// Test Code
//============================

pp <- PrettyPrinter(null, 4);
print <- pp.print.bindenv(pp);

logs <- AWSCloudWatchLogs(AWS_REGION, AWS_ACCESS_KEY, AWS_SECRET_KEY);

// Create Log Stream
params <- {
	"logGroupName": "testLogGroup",
	"logStreamName": "testLogStream"
}

logs.CreateLogStream(params, function(res) {
	print(res);
});

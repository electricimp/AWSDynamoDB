//===========================
// SETUP
//===========================

#require "PrettyPrinter.class.nut:1.0.1"
#require "AWSRequestV4.class.nut:1.0.1"
#include "AWSLambda.class.nut"


//===========================
// RUN
//===========================

pp <- PrettyPrinter(null, 4);
print <- pp.print.bindenv(pp);

// Setup DynamoDB
AWS_REGION     <- "us-west-2";
AWS_ACCESS_KEY <- "AKIAILHSWHF6ILS72R3A";
AWS_SECRET_KEY <- "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";

lambda <- AWSLambda(AWS_REGION, AWS_ACCESS_KEY, AWS_SECRET_KEY);

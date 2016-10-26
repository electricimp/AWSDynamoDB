//===========================
// RUN
//===========================

#require "AWSRequestV4.class.nut:1.0.2"
#include "AWSSES.class.nut"

const AWS_REGION = "us-west-2";
const AWS_ACCESS_KEY_ID = "AKIAILHSWHF6ILS72R3A";
const AWS_SECRET_ACCESS_KEY = "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";


//===========================
// RUN
//===========================

to<- "drew@mysticpants.com";
from<- "drew@mysticpants.com";
subject <- "SES Test";
body <- "This is a test email for AWS SES.";

ses <- AWSSES(AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY);

ses.sendEmail(to, from, subject, body function(res) {
    server.log(http.jsonencode(res));
});


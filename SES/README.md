# AWSDynamoDB

**This library is a work in progress and does not yet work.**

To add this library to your model, add the following lines to the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSES.class.nut:1.0.0"
```

**Note: [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be loaded.**

This class can be used to send emails with SES.

## Class Methods

### constructor(region, accessKeyId, secretAccessKey)

All parameters are strings. Access keys can be generated with IAM.

### SendEmail(toAddresses, fromAddress, subject, message, cb)

http://docs.aws.amazon.com/ses/latest/APIReference/API_SendEmail.html

 Parameter       | Type        | Description
---------------- | ----------- | ------------------------------
**toAddresses**  | array       | An array of strings holding email addresses to send to
**fromAddress**  | string      | The email address to send from
**subject        | string      | The subject line of the email
**message**      | string      | The message in the email
**format**       | string      | The content-type of the email (either `Text` or `Html`)
**cb**           | function    | Callback function that takes one parameter (a response table)

```squirrel

#require "AWSRequestV4.class.nut:1.0.2"
#include "AWSSES.class.nut"

const AWS_REGION = "us-west-2";
const ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const SECRET_ACCESS_KEY = "YOUR_SECRET_KEY_HERE";

ses <- AWSSES(AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY);

to      <- ["test1@gmail.com"];
from    <- "test2@gmail.com";
subject <- "SES Test";
message <- "This is a test email for AWS SES.";
format  <- "Text";

ses.SendEmail(to, from, subject, message, format="Text", function(res) {
    server.log(http.jsonencode(res));
});
```

# License

The AWSCloudWatchLogs library is licensed under the [MIT License](https://github.com/electricimp/thethingsapi/tree/master/LICENSE).

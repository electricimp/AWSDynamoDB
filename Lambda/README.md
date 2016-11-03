# AWSLambda

To add this library to your model, add the following lines to the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSLambda.class.nut:1.0.0"
```

**Note: [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be loaded.**

This class can be used to perform actions on Lambda functions.

## Class Methods

### constructor(region, accessKeyId, secretAccessKey)

All parameters are strings. Access keys can be generated with IAM.

### Invoke(params, cb)

http://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

## Example

```squirrel
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSLambda.class.nut:1.0.0"

const ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const SECRET_ACCESS_KEY = "YOUR_KEY_HERE";

lambda <- AWSLambda("us-west-2", ACCESS_KEY_ID, SECRET_ACCESS_KEY);
```

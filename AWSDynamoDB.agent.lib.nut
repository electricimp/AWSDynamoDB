// MIT License
//
// Copyright 2018 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

const AWS_DYNAMO_DB_ACTION_BATCH_GET_ITEM   = "BatchGetItem";
const AWS_DYNAMO_DB_ACTION_BATCH_WRITE_ITEM = "BatchWriteItem";
const AWS_DYNAMO_DB_ACTION_CREATE_TABLE     = "CreateTable";
const AWS_DYNAMO_DB_ACTION_DELETE_ITEM      = "DeleteItem";
const AWS_DYNAMO_DB_ACTION_DELETE_TABLE     = "DeleteTable";
const AWS_DYNAMO_DB_ACTION_DESCRIBE_LIMITS  = "DescribeLimits";
const AWS_DYNAMO_DB_ACTION_DESCRIBE_TABLE   = "DescribeTable";
const AWS_DYNAMO_DB_ACTION_GET_ITEM         = "GetItem";
const AWS_DYNAMO_DB_ACTION_LIST_TABLES      = "ListTables";
const AWS_DYNAMO_DB_ACTION_PUT_ITEM         = "PutItem";
const AWS_DYNAMO_DB_ACTION_QUERY            = "Query";
const AWS_DYNAMO_DB_ACTION_SCAN             = "Scan";
const AWS_DYNAMO_DB_ACTION_UPDATE_ITEM      = "UpdateItem";
const AWS_DYNAMO_DB_ACTION_UPDATE_TABLE     = "UpdateTable";

const AWS_DYNAMO_DB_SERVICE                 = "dynamodb";
const AWS_DYNAMO_DB_TARGET_PREFIX           = "DynamoDB_20120810";
const AWS_DYNAMO_DB_CONTENT_TYPE            = "application/x-amz-json-1.0";

class AWSDynamoDB {

    static VERSION = "1.0.0";

    _awsRequest = null;

    ////////////////////////////////////////////////////////////////////////////
    // @param {string} region
    // @param {string} accessKeyId
    // @param {string} secretAccessKey
    ////////////////////////////////////////////////////////////////////////////
    constructor(region, accessKeyId, secretAccessKey) {
        if ("AWSRequestV4" in getroottable()) {
            _awsRequest = AWSRequestV4(AWS_DYNAMO_DB_SERVICE, region, accessKeyId, secretAccessKey);
        } else {
            throw ("This class requires AWSRequestV4 - please make sure it is loaded.");
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {string} actionType
    // @param {table} params
    // @param {function} cb
    ////////////////////////////////////////////////////////////////////////////
    function action(actionType, params, cb) {
        local headers = {
            "X-Amz-Target": format("%s.%s", AWS_DYNAMO_DB_TARGET_PREFIX, actionType),
            "Content-Type": AWS_DYNAMO_DB_CONTENT_TYPE
        };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

}

// MIT License
//
// Copyright 2018-2019 Electric Imp
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

// Include library dependencies
@include "github:electricimp/AWSRequestV4/AWSRequestV4.class.nut"
// Tests need updated Promise library (need bug fix for series)
@include "github:electricimp/Promise/Promise.lib.nut"

// Enter your AWS keys here
const AWS_DYNAMO_ACCESS_KEY_ID     = "@{DYNAMO_ACCESS_KEY_ID}";
const AWS_DYNAMO_SECRET_ACCESS_KEY = "@{DYNAMO_SECRET_ACCESS_KEY}";
const AWS_DYNAMO_REGION            = "@{DYNAMO_REGION}";

// HTTP status codes
enum AWS_DYNAMO_TEST_HTTP_STATUS_CODE {
    SUCCESS_LOWER_BOUND = 200,
    SUCCESS_UPPER_BOUND = 300,
    FORBIDDEN           = 403,
    NOT_FOUND           = 404,
    BAD_REQUEST         = 400
}

// AWS response error messages
enum AWS_DYNAMO_TEST_ERROR {
    CONVERT_TO_STRING_NUM_VALUE = "NUMBER_VALUE cannot be converted to String",
    CONVERT_TO_STRING_BIG_NUM   = "class com.amazon.coral.value.json.numbers.TruncatingBigNumber can not be converted to an String",
    REOSOURCE_NOT_FOUND         = "Requested resource not found",
    PARAMETER_NOT_PRESENT       = "The parameter 'TableName' is required but was not present in the request",
    LIMIT_100                   = "1 validation error detected: Value '200' at 'limit' failed to satisfy constraint: Member must have value less than or equal to 100",
    TABLE_NOT_FOUND             = "Requested resource not found" // Note this is not the full error message "Requested resource not found: Table: <table-name> not found"
}

// Table Check Constants
const AWS_DYNAMO_TEST_MSG_WAITING        = "Table status is not ACTIVE. Scheduling next check in 5 seconds..."
const AWS_DYNAMO_TEST_ACTIVE_TIMEOUT     = 5; // This time should match the AWS_DYNAMO_TEST_MSG_WAITING message
const AWS_DYNAMO_TEST_ACTIVE_TBL_RETRIES = 6;

// Test data
const AWS_DYNAMO_TEST_UPDATE_VALUE    = "this is a new value";
const AWS_DYNAMO_TEST_FAKE_TABLE_NAME = "garbage";
const AWS_DYNAMO_TEST_FAKE_TIME       = 0;

class DynamoDBNegativeTest extends ImpTestCase {

    _db                    = null;
    _dbConfigured          = null;
    _tablename             = null;
    _KeySchema             = null;
    _AttributeDefinitions  = null;
    _ProvisionedThroughput = null;

    // Initializes AWSDynamoDB instance: _db
    // Creates a table: testTable.randNum
    function setUp() {
        // Parameters to set up categories for a table
        _KeySchema = [
            {
                "AttributeName" : "deviceId",
                "KeyType"       : "HASH"
            }, 
            {
                "AttributeName" : "time",
                "KeyType"       : "RANGE"
            }
        ];
        _AttributeDefinitions = [
            {
                "AttributeName" : "deviceId",
                "AttributeType" : "S"
            }, 
            {
                "AttributeName" : "time",
                "AttributeType" : "S"
            }
        ];
        _ProvisionedThroughput = {
            "ReadCapacityUnits"  : 5,
            "WriteCapacityUnits" : 5
        };
        _dbConfigured = false;

        // Create class instance
        _db = AWSDynamoDB(AWS_DYNAMO_REGION, AWS_DYNAMO_ACCESS_KEY_ID, AWS_DYNAMO_SECRET_ACCESS_KEY);

        // Delete all DB tables, then configure a table for tests
        return _getTables().then(_clearAndConfigure.bindenv(this), _onDBCleanupFail.bindenv(this));
    }

    // Check that putting an item in a non-existent table returns HTTP
    // statuscode 400 and the correct error message reveived from AWS
    function testFailPutItem() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");

        local params = {
            "TableName": AWS_DYNAMO_TEST_FAKE_TABLE_NAME,
            "Item" : {
                "deviceId" : {
                    "S": imp.configparams.deviceid
                },
                "time" : {
                    "S" : time().tostring()
                },
                "status" : {
                    "BOOL" : true
                }
            }
        };

        return Promise(function(resolve, reject) {
            _db.action(AWS_DYNAMO_DB_ACTION_PUT_ITEM, params, function(resp) {
                try {
                    local statuscode = resp.statuscode;
                    assertEqual(statuscode, AWS_DYNAMO_TEST_HTTP_STATUS_CODE.BAD_REQUEST, "Received unexpected status code: " + statuscode);
                    
                    local respMsg = http.jsondecode(resp.body).message;
                    assertEqual(respMsg, AWS_DYNAMO_TEST_ERROR.REOSOURCE_NOT_FOUND, "Received unexpected error message from AWS: " + respMsg);

                    return resolve("Put action request with bad params did not update DB table");
                } catch (ex) {
                    return reject("Put action request with bad params test failed with exception: " + ex);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // Check that getting a number as string returns HTTP statuscode 400
    // and the correct error message from AWS
    function testFailGetItem() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");

        local getParams = {
            "TableName"       : _tablename,
            "AttributesToGet" : ["time", "status"],
            "ConsistentRead"  : false, 
            "Key"             : {
                "deviceId" : {"S" : imp.configparams.deviceid},
                "time"     : {"S" : AWS_DYNAMO_TEST_FAKE_TIME}
            }
        };

        return Promise(function(resolve, reject) {
            _db.action(AWS_DYNAMO_DB_ACTION_GET_ITEM, getParams, function(resp) {
                try {
                    local statuscode = resp.statuscode;
                    assertEqual(statuscode, AWS_DYNAMO_TEST_HTTP_STATUS_CODE.BAD_REQUEST, "Received unexpected status code: " + statuscode);
                    
                    // This action returns "Message" not "message"
                    local respMsg = http.jsondecode(resp.body).Message; 
                    assertEqual(respMsg, AWS_DYNAMO_TEST_ERROR.CONVERT_TO_STRING_NUM_VALUE, "Received unexpected error message from AWS: " + respMsg);

                    return resolve("Get action request with bad params did not update DB table");
                } catch (ex) {
                    return reject("Get action request with bad params test failed with exception: " + ex);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // Try to update table without the tablename parameter
    function testFailUpdateItem() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");

        local params = {
            "ProvisionedThroughput" : {
                "ReadCapacityUnits"  : 6,
                "WriteCapacityUnits" : 6
            }
        };

        return Promise(function(resolve, reject) {
            _db.action(AWS_DYNAMO_DB_ACTION_UPDATE_TABLE, params, function(resp) {
                try {
                    local statuscode = resp.statuscode;
                    assertEqual(statuscode, AWS_DYNAMO_TEST_HTTP_STATUS_CODE.BAD_REQUEST, "Received unexpected status code: " + statuscode);

                    local respMsg = http.jsondecode(resp.body).message;
                    assertEqual(respMsg, AWS_DYNAMO_TEST_ERROR.PARAMETER_NOT_PRESENT, "Received unexpected error message from AWS: " + respMsg);

                    return resolve("Update action request with bad params did not update DB table");
                } catch (ex) {
                    return reject("Update action request with bad params test failed with exception: " + ex);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    function testFailListTables() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");

        local params = {
            "Limit" : 200
        };

        return Promise(function(resolve, reject) {
            _db.action(AWS_DYNAMO_DB_ACTION_LIST_TABLES, params, function(resp) {
                try {
                    local respMsg = http.jsondecode(resp.body).message;
                    assertEqual(respMsg, AWS_DYNAMO_TEST_ERROR.LIMIT_100, "Received unexpected error message from AWS: " + respMsg);

                    return resolve("List action request with bad params failed with expected limit of 100 error");
                } catch (ex) {
                    return reject("List action request with bad params test failed with exception: " + ex);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    function tearDown() {
        // Delete all DB tables
        return _getTables().then(_clearDB.bindenv(this), _onDBCleanupFail.bindenv(this));
    }

    // Setup and teardown helper functions that return Promises
    // --------------------------------------------------------------------

    function _getTables() {
        return Promise(function (resolve, reject) {
            local reqParams = { "ExclusiveStartTableName": "testTable" };
            _db.action(AWS_DYNAMO_DB_ACTION_LIST_TABLES, reqParams, function(resp) {
                try {
                    local statuscode = resp.statuscode;
                    if (!_respIsSuccessful(statuscode)) {
                        // Unsuccessful response from Dynamo DB
                        local errMsg = "Error requesting list of tables, status code: " + statuscode;
                        return reject(errMsg);
                    }

                    local tblNames = http.jsondecode(resp.body).TableNames;
                    return resolve(tblNames);
                } catch(ex) {
                    local errMsg = "Caught exception processing list of tables resonse: " + ex;
                    return reject(errMsg);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    function _onDBCleanupFail(errMsg) {
        // Setup failed. Clear DB instance, so we don't bother running any tests.
        _dbConfigured = false;
        // Return the error message
        return errMsg;
    }

    function _clearAndConfigure(tblNames) {
        local tasks = _createDelQueue(tblNames);
        return Promise.serial(tasks).then(_configureTestDB.bindenv(this), _onDBCleanupFail.bindenv(this));
    }

    function _deleteTable(tblName) {
        info("Starting ACTIVE check and delete for table: " + tblName);
        // Don't resolve until retries have completed
        return Promise(function(resolve, reject) {
            local reqParams = { "TableName" : tblName };
            // Loop to check that table is active
            _checkTableIsActive(reqParams, AWS_DYNAMO_TEST_ACTIVE_TBL_RETRIES, true, function(errMsg) {
                if (errMsg != null) return reject(errMsg);

                // Delete table
                _db.action(AWS_DYNAMO_DB_ACTION_DELETE_TABLE, reqParams, function(resp) {
                    local statuscode = resp.statuscode;

                    if (!_respIsSuccessful(statuscode)) {
                        // Create error if request was unsuccessful
                        local err = _getRespErrMsg(resp, "Delete table request failed. ");
                        return reject(err);
                    }

                    local successMsg = tblName + " table successfully deleted";
                    info(successMsg)
                    return resolve(successMsg);
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this))
    }

    function _configureTestDB(msg) {
        // Parameter "msg" is a message from last task promise that resolved
        return Promise(function(resolve, reject) {
            // Create a random table name
            local randNum = (1.0 * math.rand() / RAND_MAX) * (1000 + 1);
            _tablename = "testTable." + randNum;

            local reqParams = {
                "AttributeDefinitions"  : _AttributeDefinitions,
                "KeySchema"             : _KeySchema,
                "ProvisionedThroughput" : _ProvisionedThroughput,
                "TableName"             : _tablename
            };

            info("Creating test db: " + _tablename);
            // Create a table with random name per test testTable.randNum
            _db.action(AWS_DYNAMO_DB_ACTION_CREATE_TABLE, reqParams, function (resp) {
                local statuscode = resp.statuscode;
                // Handle unsuccessful response
                info("Create table resp status code: " + statuscode);
                if (!_respIsSuccessful(statuscode)) {
                    local errMsg = _getRespErrMsg(resp, "Failed to create table during setup of  @{__FILE__}. ");
                    return reject(errMsg);
                }

                local checkParams = {
                    "TableName": _tablename
                };

                // Wait and check DB for table to become ACTIVE
                imp.wakeup(AWS_DYNAMO_TEST_ACTIVE_TIMEOUT, function() {
                    _checkTableIsActive(checkParams, AWS_DYNAMO_TEST_ACTIVE_TBL_RETRIES, false, function(errMsg) {
                        if (errMsg == null) {
                            _dbConfigured = true;
                            return resolve("Setup for @{__FILE__} test complete");
                        } else {
                            return reject(error);
                        }
                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));
    }

    function _clearDB(tblNames) {
        local tasks = _createDelQueue(tblNames);
        return Promise.serial(tasks).then(
            function(msg) { 
                // Parameter "msg" is a message from last task promise that resolved
                _db = null;
                return "DB tables deleted, teardown for @{__FILE__} tests complete"; 
            }.bindenv(this), 
            _onDBCleanupFail.bindenv(this)
        );        
    }

    // // Helper functions
    // // --------------------------------------------------------------------

    function _createDelQueue(tblNames) {
        local numTbls = tblNames.len();
        local tasks = [];

        if (numTbls == 0) {
            return tasks;
        }

        info("Found " + numTbls + " table(s)");
        foreach(name in tblNames) {
            info("Adding delete table task for table: " + name);
            local tblName = name;
            local delTbl = function() {
                return _deleteTable(tblName);
            }
            tasks.push(delTbl.bindenv(this));
        }

        return tasks;
    }

    // Loop that checks that a table is ACTIVE
    function _checkTableIsActive(reqParams, ctr, areDeleting, onDone) {
        _db.action(AWS_DYNAMO_DB_ACTION_DESCRIBE_TABLE, reqParams, function(resp) {
            local statuscode = resp.statuscode;
            if (!_respIsSuccessful(statuscode)) {
                // TODO: If too many requests error continues to be an issue add a check/handle
                // error "The rate of control plane requests made by this account is too high"

                local errMsg = _getRespErrMsg(resp, "Describe table request failed. ");
                if (areDeleting && statuscode == AWS_DYNAMO_TEST_HTTP_STATUS_CODE.BAD_REQUEST 
                    && errMsg.find(AWS_DYNAMO_TEST_ERROR.TABLE_NOT_FOUND) != null) {
                    // Trigger success flow if we were trying to delete the table
                    info("Table no longer exists");
                    onDone(null);
                } else {
                    onDone(errMsg);
                }
                return;
            }

            try {
                local status = http.jsondecode(resp.body).Table.TableStatus;
                info("Table status: " + status);
                if (status == "ACTIVE") {
                    // Table active and ready to delete
                    onDone(null);
                    return;
                }
            } catch(ex) {
                info("Error parsing describe table response: " + ex);
                info(resp.body);
            }

            if (ctr-- == 0) {
                local errMsg = "Table status is not ACTIVE after " + AWS_DYNAMO_TEST_ACTIVE_TBL_RETRIES + " checks";
                onDone(errMsg);
                return;
            }

            // Since request was successful, wait and make another request for table description
            info(AWS_DYNAMO_TEST_MSG_WAITING);
            // Back off requests to avoid rate limits
            imp.wakeup(AWS_DYNAMO_TEST_ACTIVE_TIMEOUT, function() {
                _checkTableIsActive(reqParams, ctr, areDeleting, onDone);
            }.bindenv(this));
        }.bindenv(this));
    }

    function _respIsSuccessful(statuscode) {
        return (statuscode >= AWS_DYNAMO_TEST_HTTP_STATUS_CODE.SUCCESS_LOWER_BOUND && 
                statuscode < AWS_DYNAMO_TEST_HTTP_STATUS_CODE.SUCCESS_UPPER_BOUND);
    }

    function _getRespErrMsg(resp, baseMsg = "Dynamo DB request failed. ") {
        local errMsg = baseMsg + "Statuscode: " + resp.statuscode;
        try {
            errMsg = errMsg + ". Message: " + http.jsondecode(resp.body).message;
        } catch(ex) {
            info("Error parsing response message: " + resp.body);
            info(ex);
        }
        return errMsg;
    }

}
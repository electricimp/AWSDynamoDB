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
const AWS_DYNAMO_TEST_ACTIVE_TBL_RETRIES = 10;

// Test data
const AWS_DYNAMO_TEST_UPDATE_VALUE    = "this is a new value";
const AWS_DYNAMO_TEST_FAKE_TABLE_NAME = "garbage";
const AWS_DYNAMO_TEST_FAKE_TIME       = 0;


class DynamoDBPositiveTest extends ImpTestCase {

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

    // Test putting a item in a table then retrieving it via a get
    // specifically checking the time at which the item is put in is stored
    // and that we are retrieving it via a get
    function testGetItem() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");
        
        local expectedItemTime = time().tostring();

        local getParams = {
            "TableName"       : _tablename,
            "ConsistentRead"  : false,
            "AttributesToGet" : ["time", "status"],
            "Key"             : {
                "deviceId" : {"S" : imp.configparams.deviceid},
                "time"     : {"S" : expectedItemTime}
            }
        };

        return _putItem(expectedItemTime)
            .then(
                function(msg) {
                    return Promise(function(resolve, reject) {
                        // Confirm PUT request altered the DB
                        _db.action(AWS_DYNAMO_DB_ACTION_GET_ITEM, getParams, function(getResp) {
                            local statuscode = getResp.statuscode;
                            if (!_respIsSuccessful(statuscode)) {
                                local errMsg = _getRespErrMsg(getResp, "GET ITEM request failed. ");
                                return reject(errMsg);
                            }
                            
                            try {
                                local actualItemTime = http.jsondecode(getResp.body).Item.time.S;
                                assertEqual(expectedItemTime, actualItemTime, "Expected itemTime: " + expectedItemTime + " did not match received itemTime: " + actualItemTime);
                                return resolve("GET ITEM test successful");
                            } catch(ex) {
                                return reject("GET ITEM test failed with exception: " + ex);
                            }
                        }.bindenv(this)); // GET ITEM closure
                    }.bindenv(this)) // Promise closure
                }.bindenv(this),
                function(errMsg) {
                    return "GET ITEM test failed:" + errMsg;
                }.bindenv(this));
    }

    // Add a new item to an existing table
    // Check that response contains the correct value added in the returned Attributes section
    // Should only return updated Items
    function testUpdateItem() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");

        local expectedItemTime = time().tostring();

        local updateParams = {
            "TableName"                 : _tablename,
            "UpdateExpression"          : "SET newVal = :newVal",
            "ReturnValues"              : "UPDATED_NEW",
            "ExpressionAttributeValues" : {
                ":newVal": { "S" : AWS_DYNAMO_TEST_UPDATE_VALUE }
            },
            "Key"                       : {
                "deviceId" : {"S" : imp.configparams.deviceid},
                "time"     : {"S" : expectedItemTime}
            }
        };

        return _putItem(expectedItemTime)
            .then(
                function(msg) {
                    return Promise(function(resolve, reject) {
                        // Confirm PUT request altered the DB
                        _db.action(AWS_DYNAMO_DB_ACTION_UPDATE_ITEM, updateParams, function(updateResp) {
                            local statuscode = updateResp.statuscode;
                            if (!_respIsSuccessful(statuscode)) {
                                local errMsg = _getRespErrMsg(updateResp, "UPDATE ITEM request failed. ");
                                return reject(errMsg);
                            }
                            
                            try {
                                local attrs             = http.jsondecode(updateResp.body).Attributes;
                                local expectedNumAttrs = 1;
                                local actualNumAttrs   = attrs.len();
                                local actualNewVal     = attrs.newVal.S;
                                assertEqual(expectedNumAttrs, actualNumAttrs, "Received unexpected number of altered attributes: " + actualNumAttrs);
                                assertEqual(AWS_DYNAMO_TEST_UPDATE_VALUE, actualNewVal, "Received unexpected new value: " + actualNewVal);

                                return resolve("UPDATE ITEM test successful");
                            } catch(ex) {
                                return reject("UPDATE ITEM test failed with exception: " + ex);
                            }
                        }.bindenv(this)); // UPDATE ITEM closure
                    }.bindenv(this)); // Promise closure
                }.bindenv(this),
                function(errMsg) {
                    return "UPDATE ITEM test failed:" + errMsg;
                }.bindenv(this));
    }

    // Deletes an item
    // checks the http response code indicating a successful response
    function testDeleteItem() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");

        local expectedItemTime = time().tostring();

        local deleteParams = {
            "TableName"    : _tablename,
            "ReturnValues" : "ALL_OLD",
            "Key"          : {
                "deviceId": {"S" : imp.configparams.deviceid},
                "time"    : {"S" : expectedItemTime}
            }
        };

        return _putItem(expectedItemTime)
            .then(
                function(msg) {
                    return Promise(function(resolve, reject) {
                        _db.action(AWS_DYNAMO_DB_ACTION_DELETE_ITEM, deleteParams, function(delResp) {
                            try {
                                local statuscode = delResp.statuscode;
                                local expected = AWS_DYNAMO_TEST_HTTP_STATUS_CODE.SUCCESS_LOWER_BOUND;
                                assertEqual(expected, statuscode, "Received unexpected status code: " + statuscode);
                                return resolve("DELETE ITEM test successful");
                            } catch(ex) {
                                return reject("DELETE ITEM test failed with exception: " + ex);
                            }
                        }.bindenv(this)); // DELETE ITEM closure
                    }.bindenv(this)); ; // Promise closure
                }.bindenv(this),
                function(errMsg) {
                    return "DELETE ITEM test failed:" + errMsg;
                }.bindenv(this));
    }

    // Create a specific table called testTable wait for it to be created.
    // Then write a batch message to it.
    // Wait for the table to be updated. Then check if updates went through via scan
    function testBatchWriteItem() {
        local tblName     = "testTable";
        local expBatchNum = "1";

        local PutRequest = {
            "Item": {
                "deviceId"    : {"S" : imp.configparams.deviceid},
                "time"        : {"S" : time().tostring()},
                "batchNumber" : {"N" : expBatchNum}
            }
        };

        local writeParams = {
            "RequestItems" : { [tblName] = [{"PutRequest" : PutRequest}] }
        };

        local scanParams = {"TableName": tblName};

        // TODO: Look at creating table with unique name and let teardown delete all tables?
        return _createTable(tblName)
            .then(
                function(msg) {
                    info(msg);
                    return _writeBatchItem(writeParams);
                }.bindenv(this),
                _onBatchWriteFail.bindenv(this))
            .then(
                function(msg) {
                    info(msg);
                    return _confirmActive(tblName);
                }.bindenv(this),
                _onBatchWriteFail.bindenv(this))
            .then(
                function(msg) {
                    info(msg);
                    return Promise(function(resolve, reject) {
                        _db.action(AWS_DYNAMO_DB_ACTION_SCAN, scanParams, function(scanResp) {
                            try {
                                local actualBatchNum = http.jsondecode(scanResp.body).Items[0].batchNumber.N;
                                assertEqual(expBatchNum, actualBatchNum, "Received unexpected batch number: " + actualBatchNum);
                                return resolve("SCAN request successful");
                            } catch(ex) {
                                return reject("BATCH WRITE ITEM test failed: " + ex);
                            }
                        }.bindenv(this));
                    }.bindenv(this));
                }.bindenv(this),
                _onBatchWriteFail.bindenv(this))
            .then(
                function(msg) {
                    info(msg);
                    return _deleteTable(tblName);
                }.bindenv(this),
                _onBatchWriteFail.bindenv(this))
            .then(
                function(msg) {
                    info(msg);
                    return "BATCH WRITE ITEM test successful";
                }.bindenv(this),
                _onBatchWriteFail.bindenv(this));
    }

    // create a specific table called testTable2 wait for it to be created.
    // Then write a batch message to it.
    // Use the BatchGetItem and test if the correct items are returned
    // Note order of insertion isn't consistent
    function testBatchGetItem() {
        local tblName      = "testTable2";
        local expItemTime1 = time().tostring(); 
        local expItemTime2 = (time() + 1).tostring();
        local expBatchNum1 = "1";
        local expBatchNum2 = "2";
        local deviceId     = imp.configparams.deviceid;

        local PutRequest1 = {
            "Item": {
                "deviceId"    : {"S" : deviceId},
                "time"        : {"S" : expItemTime1},
                "batchNumber" : {"N" : expBatchNum1}
            }
        };
        local PutRequest2 = {
            "Item": {
                "deviceId"    : {"S" : deviceId},
                "time"        : {"S" : expItemTime2},
                "batchNumber" : {"N" : expBatchNum2}
            }
        };

        local writeParams = {
            ["RequestItems"] = { 
                [tblName] = [
                    {["PutRequest"] = PutRequest1},
                    {["PutRequest"] = PutRequest2}
                ] 
            }
        };

        local getParams = {
            ["RequestItems"] = { 
                [tblName] = {
                    ["Keys"] = [
                        {["deviceId"] = {"S" : deviceId},
                         ["time"]     = {"S" : expItemTime1}},
                        {["deviceId"] = {"S" : deviceId},
                         ["time"]     = {"S" : expItemTime2}}
                    ]
                }
            }
        };

        // TODO: Look at creating table with unique name and let teardown delete all tables?
        return _createTable(tblName)
            .then(
                function(msg) {
                    info(msg);
                    return _writeBatchItem(writeParams);
                }.bindenv(this),
                _onBatchGetFail.bindenv(this))
            .then(
                function(msg) {
                    info(msg);
                    return _confirmActive(tblName);
                }.bindenv(this),
                _onBatchGetFail.bindenv(this))
            .then(
                function(msg) {
                    info(msg);
                    return Promise(function(resolve, reject) {
                        _db.action(AWS_DYNAMO_DB_ACTION_BATCH_GET_ITEM, getParams, function(bgiResp) {
                            local statuscode = bgiResp.statuscode;

                            if (!_respIsSuccessful(statuscode)) {
                                local errMsg = _getRespErrMsg(bgiResp, "GET BATCH ITEM request failed. ");
                                return reject(errMsg);
                            }

                            try {
                                local respsForTbl = http.jsondecode(bgiResp.body)["Responses"][tblName];
                                local numResps    = respsForTbl.len();
                                // Based on write data and get query, we expect 2 responses
                                assertEqual(2, numResps, "Received unexpected number of items: " + numResps);
                                foreach(item in respsForTbl) {
                                    local batchNum = item.batchNumber.N;
                                    local itemTime = item.time.S;
                                    local assertError = "Received unexpected item time " + itemTime + " from batch item " + batchNum;
                                    
                                    switch(batchNum) {
                                        case expBatchNum1:
                                            assertEqual(expItemTime1, itemTime, assertError);
                                            break;
                                        case expBatchNum2:
                                            assertEqual(expItemTime2, itemTime, assertError);
                                            break;
                                        default: 
                                            throw assertError;
                                    }
                                }
                                return resolve("GET BATCH ITEM request successful")
                            } catch(ex) {
                                return reject("GET BATCH ITEM request failed: " + ex);
                            }
                        }.bindenv(this));
                    }.bindenv(this));
                }.bindenv(this),
                _onBatchGetFail.bindenv(this))
            .then(
                function(msg) {
                    info(msg);
                    return _deleteTable(tblName);
                }.bindenv(this),
                _onBatchGetFail.bindenv(this))
            .then(
                function(msg) {
                    info(msg);
                    return "BATCH GET ITEM test successful";
                }.bindenv(this),
                _onBatchGetFail.bindenv(this));
    }

    // Test create a table, checks that the tablename, keyschema and
    // attribute definitions of created table match
    function testCreateTable() {

        local randNum = (1.0 * math.rand() / RAND_MAX) * (1000 + 1);
        local tblName = "testTable." + randNum;

        return Promise(function(resolve, reject) {
            local createParams = {
                "AttributeDefinitions"  : _AttributeDefinitions,
                "KeySchema"             : _KeySchema,
                "ProvisionedThroughput" : _ProvisionedThroughput,
                "TableName"             : tblName
            };

            info("Creating test db: " + tblName);
            // Create a table with random name per test testTable.randNum
            _db.action(AWS_DYNAMO_DB_ACTION_CREATE_TABLE, createParams, function (resp) {
                local statuscode = resp.statuscode;
                // Handle unsuccessful response
                info("CREATE TABLE resp status code: " + statuscode);
                if (!_respIsSuccessful(statuscode)) {
                    local errMsg = _getRespErrMsg(resp, "CREATE TABLE " + tblName + " request failed. ");
                    return reject(errMsg);
                }

                // Run checks (NOTE: these checks are why we are not using the _createTable helper function)
                try {
                    local tableDescription  = http.jsondecode(resp.body).TableDescription;
                    local receivedTblName   = tableDescription.TableName;
                    local receivedAttrDefs  = tableDescription.AttributeDefinitions;
                    local receivedKeySchema = tableDescription.KeySchema;

                    assertEqual(tblName, receivedTblName, "Received unexpected table name: " + receivedTblName);
                    assertDeepEqual(_AttributeDefinitions, receivedAttrDefs, "Received unexpected attribute definitions");
                    assertDeepEqual(_KeySchema, receivedKeySchema, "Received unexpected key schema");

                    return _deleteTable(receivedTblName).then(
                        function(msg) {
                            info(msg);
                            return resolve("CREATE TABLE test successful");
                        }.bindenv(this),
                        function(error) {
                            return reject("CREATE TABLE test failed: " + error);
                        }.bindenv(this)
                    );
                } catch (ex) {
                    return reject("CREATE TABLE test failed: " + ex);
                }
            }.bindenv(this)); // CREATE TABLE closure
        }.bindenv(this)); // Promise clousure
    }

    // Obtains a description of a table checks that the returned tableName is the one that we were checking for
    // also check for keyschema and AttributeDefinitions
    function testDescribeTable() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");

        return Promise(function(resolve, reject) {
            local descParams = {"TableName": _tablename};

            _db.action(AWS_DYNAMO_DB_ACTION_DESCRIBE_TABLE, descParams, function(resp) {
                local statuscode = resp.statuscode;

                // Handle unsuccessful response
                if (!_respIsSuccessful(statuscode)) {
                    local errMsg = _getRespErrMsg(resp, "DESCRIBE TABLE " + _tablename + " request failed. ");
                    return reject(errMsg);
                }

                try {
                    local tblDesc      = http.jsondecode(resp.body).Table;
                    local tblName      = tblDesc.TableName;
                    local tblAttrs     = tblDesc.AttributeDefinitions;
                    local tblKeySchema = tblDesc.KeySchema;

                    assertEqual(_tablename, tblName, "Received unexpected table name: " + tblName);
                    assertDeepEqual(_AttributeDefinitions, tblAttrs, "Received unexpected table attributes");
                    assertDeepEqual(_KeySchema, tblKeySchema, "Received unexpected table key schema");

                    return resolve("DESCRIBE TABLE test successful");
                } catch (ex) {
                    reject("DESCRIBE TABLE test failed: " + ex);
                }
            }.bindenv(this)); // DESCRIBE TABLE closure
        }.bindenv(this)); // Promise closure
    }

    // Test the update table function changes the tables
    // describes the table once it is updated to see if changes were made
    function testUpdateTable() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");

        local readCapUnits  = 6;
        local writeCapUnits = 6;

        local updateParams = {
            "TableName"             : _tablename,
            "ProvisionedThroughput" : {
                "ReadCapacityUnits"  : readCapUnits,
                "WriteCapacityUnits" : writeCapUnits
            }
        };

        return _updateTable(updateParams)
            .then(
                function(msg) {
                    return _confirmActive(_tablename);
                }.bindenv(this),
                function(errMsg) {
                    return "UPDATE TABLE test failed: " + errMsg;
                }.bindenv(this))
            .then(
                function(msg) {
                    local descParams = {"TableName" : _tablename};
                    return Promise(function(resolve, reject) {
                        _db.action(AWS_DYNAMO_DB_ACTION_DESCRIBE_TABLE, descParams, function(descResp) {
                            local statuscode = descResp.statuscode;
                            if (!_respIsSuccessful(statuscode)) {
                                local errMsg = _getRespErrMsg(descResp, "UPDATE TABLE " + _tablename + " request failed. ");
                                return reject(errMsg);
                            }

                            try {
                                local provThruPut = http.jsondecode(descResp.body).Table.ProvisionedThroughput;
                                assertEqual(readCapUnits, provThruPut.ReadCapacityUnits, "Received unexpected read capacity units: " + provThruPut.ReadCapacityUnits);
                                assertEqual(writeCapUnits, provThruPut.WriteCapacityUnits, "Received unexpected write capacity units: " + provThruPut.WriteCapacityUnits);
                                return resolve("UPDATE TABLE test successful");
                            } catch(ex) {
                                return reject("UPDATE TABLE test failed: " + ex);
                            }
                        }.bindenv(this));
                    }.bindenv(this));
                }.bindenv(this),
                function(errMsg) {
                    return "UPDATE TABLE test failed: " + errMsg;
                }.bindenv(this));
    }

    // creates a table then deletes it
    // checks for a 200 response
    // checks that the status of the table is deleting
    // waits for the table to no longer be findable hence deleted
    function testDeleteTable() {
        local randNum = (1.0 * math.rand() / RAND_MAX) * (1000 + 1);
        local tblName = "testTable." + randNum;

        local params = {
            "TableName": tblName
        };

        return _createTable(tblName)
            .then(
                function(msg) {
                    info(msg);
                    return _deleteTable(tblName);
                }.bindenv(this),
                function(errMsg) {
                    return "DELETE TABLE test failed: " + errMsg;
                }.bindenv(this))
            .then(
                function(msg) {
                    info(msg);
                    return _confirmActive(tblName, true);
                }.bindenv(this),
                function(errMsg) {
                    return "DELETE TABLE test failed: " + errMsg;
                }.bindenv(this))
            .then(
                function(msg) {
                    info(msg);
                    return "DELETE TABLE test successful";
                }.bindenv(this),
                function(errMsg) {
                    return "DELETE TABLE test failed: " + errMsg;
                }.bindenv(this))
    }

    // tests the DescribeLimits function returns values for the provisioned
    // capacity limits < 100
    function testDescribeLimits() {
        return Promise(function(resolve, reject) {
            _db.action(AWS_DYNAMO_DB_ACTION_DESCRIBE_LIMITS, {}, function(resp) {
                try {
                    local statuscode = resp.statuscode;
                    local body = http.jsondecode(resp.body);

                    assertTrue(_respIsSuccessful(statuscode), "Received unexpected status code: " + statuscode);
                    assertTrue(_isNotNull(body.TableMaxWriteCapacityUnits), "Received unexpected table max write capacity units: null");
                    assertTrue(_isNotNull(body.AccountMaxWriteCapacityUnits), "Received unexpected account max write capacity units: null");
                    assertTrue(_isNotNull(body.TableMaxReadCapacityUnits), "Received unexpected table max read capacity units: null");
                    assertTrue(_isNotNull(body.AccountMaxReadCapacityUnits), "Received unexpected account max read capacity units: null");

                    return resolve("DESCRIBE LIMITS test successful");
                } catch (ex) {
                    return reject("DESCRIBE LIMITS test failed: " + ex);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // return an array of TableNames
    // checks for _tablename is listed
    function testListTables() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");

        return _getTables()
            .then(
                function(tblNames) {
                    assertGreater(tblNames.len(), 0, "LIST TABLES request did not return any tables");
                    local testTblIdx = tblNames.find(_tablename);
                    assertTrue(_isNotNull(testTblIdx), "LIST TABLES request did not return test table");
                    return "LIST TABLES test successful";
                }.bindenv(this), 
                function(errMsg) {
                    return "LIST TABLES test failed: " + errMsg;
                }.bindenv(this))
    }

    // tests a query and checks that the retrieved values were aligned
    function testQuery() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");

        return Promise(function(resolve, reject) {
            local deviceId = imp.configparams.deviceid;

            local queryParams = {
                "TableName"                 : _tablename,
                "KeyConditionExpression"    : "deviceId = :deviceId",
                "ExpressionAttributeValues" : {
                    ":deviceId": {"S": deviceId}
                }
            };

            _db.action(AWS_DYNAMO_DB_ACTION_QUERY, queryParams, function(resp) {
                local statuscode = resp.statuscode;
                if (!_respIsSuccessful(statuscode)) {
                    local errMsg = _getRespErrMsg(resp, "QUERY request failed. ");
                    return reject(errMsg);
                }

                try {
                    local devIdItem0 = http.jsondecode(resp.body).Items[0];
                    assertEqual(devIdItem0, deviceId, "Device did not match query request");
                    return resolve("QUERY test successful");
                } catch(ex) {
                    return resolve("QUERY test failed: " + ex);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // test the scan function returns both the correct value of deviceId
    // and only returns a single item as the table should only have 1 item.
    function testScan() {
        assertTrue(_dbConfigured, "DB is not configured. Aborting test.");

        return Promise(function(resolve, reject) {
            local scanParams   = {"TableName": _tablename};
            local deviceId     = imp.configparams.deviceid;
            local expScanCount = 1;

            _db.action(AWS_DYNAMO_DB_ACTION_SCAN, scanParams, function(scanResp) {
                local statuscode = scanResp.statuscode;
                if (!_respIsSuccessful(statuscode)) {
                    local errMsg = _getRespErrMsg(scanResp, "SCAN request failed. ");
                    return reject(errMsg);
                }

                try {
                    local body      = http.jsondecode(scanResp.body);
                    local scanDevId = body.Items[0].deviceId.S;
                    local scanCount = body.ScannedCount;

                    assertEqual(deviceId, scanDevId, "Received unexpected device id: " + scanDevId);
                    assertEqual(expScanCount, scanCount, "Received unexpected scan count: " + scanCount);
                    return resolve("SCAN test successful");
                } catch(ex) {
                    return reject("SCAN test failed: " + ex);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // Deletes all table(s) used throughout the tests
    function tearDown() {
        // Delete all DB tables
        return _getTables().then(_clearDB.bindenv(this), _onDBCleanupFail.bindenv(this));
    }

    // Helper functions that return Promises
    // --------------------------------------------------------------------

    function _putItem(expectedItemTime) {
        local putParams = {
            "TableName" : _tablename,
            "Item"      : {
                "deviceId" : {"S" : imp.configparams.deviceid},
                "time"     : {"S" : expectedItemTime},
                "status"   : {"BOOL" : true}
            }
        };

        return Promise(function(resolve, reject) {
            _db.action(AWS_DYNAMO_DB_ACTION_PUT_ITEM, putParams, function(putResp) {
                local statuscode = putResp.statuscode;
                if (!_respIsSuccessful(statuscode)) {
                    local errMsg = _getRespErrMsg(putResp, "PUT ITEM request failed. ");
                    return reject(errMsg);
                }
                return resolve("GET ITEM test successful");
            }.bindenv(this));
        }.bindenv(this));
    }

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
                    return resolve(successMsg);
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this))
    }

    function _createTable(tblName) {
        return Promise(function(resolve, reject) {
            local reqParams = {
                "AttributeDefinitions"  : _AttributeDefinitions,
                "KeySchema"             : _KeySchema,
                "ProvisionedThroughput" : _ProvisionedThroughput,
                "TableName"             : tblName
            };

            info("Creating test db: " + tblName);
            // Create a table with random name per test testTable.randNum
            _db.action(AWS_DYNAMO_DB_ACTION_CREATE_TABLE, reqParams, function (resp) {
                local statuscode = resp.statuscode;
                // Handle unsuccessful response
                info("CREATE TABLE resp status code: " + statuscode);
                if (!_respIsSuccessful(statuscode)) {
                    local errMsg = _getRespErrMsg(resp, "CREATE TABLE " + tblName + " request failed. ");
                    return reject(errMsg);
                }

                local checkParams = {
                    "TableName": tblName
                };

                // Wait and check DB for table to become ACTIVE
                imp.wakeup(AWS_DYNAMO_TEST_ACTIVE_TIMEOUT, function() {
                    _checkTableIsActive(checkParams, AWS_DYNAMO_TEST_ACTIVE_TBL_RETRIES, false, function(errMsg) {
                        return (errMsg == null) ? resolve(tblName + " table CREATED and ACTIVE") : reject(errMsg);
                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));
    }

    function _clearAndConfigure(tblNames) {
        local tasks = _createDelQueue(tblNames);
        return Promise.serial(tasks).then(_configureTestDB.bindenv(this), _onDBCleanupFail.bindenv(this));
    }

    function _configureTestDB(msg) {
        // Parameter "msg" is a message from last task promise that resolved

        // Create a random table name
        local randNum = (1.0 * math.rand() / RAND_MAX) * (1000 + 1);
        _tablename = "testTable." + randNum;

        return _createTable(_tablename)
            .then(
                function(msg) {
                    _dbConfigured = true;
                    info(_tablename + " table CREATED and ACTIVE");
                    return "Setup for @{__FILE__} test complete";
                }.bindenv(this),
                function(errMsg) {
                    info(errMsg);
                    return "Setup for @{__FILE__} failed";
                }.bindenv(this));
    }

    function _clearDB(tblNames) {
        local tasks = _createDelQueue(tblNames);
        return Promise.serial(tasks)
            .then(
                function(msg) { 
                    info(msg);
                    // Parameter "msg" is a message from last task promise that resolved
                    _db = null;
                    return "DB tables deleted, teardown for @{__FILE__} tests complete"; 
                }.bindenv(this), 
                _onDBCleanupFail.bindenv(this));        
    }

    function _confirmActive(tblName, areDeleting = false) {
        local checkParams = {
            "TableName": tblName
        };

        return Promise(function(resolve, reject) {
            _checkTableIsActive(checkParams, AWS_DYNAMO_TEST_ACTIVE_TBL_RETRIES, areDeleting, function(errMsg) {
                // NOTE: if areDeleting flag is set to true the table might already be deleted, and not active
                return (errMsg == null) ? resolve("Table is ACTIVE or DELETED") : reject(errMsg);
            }.bindenv(this)); 
        }.bindenv(this))        
    }

    function _writeBatchItem(writeParams) {
        return Promise(function(resolve, reject) {
            _db.action(AWS_DYNAMO_DB_ACTION_BATCH_WRITE_ITEM, writeParams, function(bwiResp) {
                local statuscode = bwiResp.statuscode;
                return (_respIsSuccessful(statuscode)) ? resolve("BATCH WRITE request successful") : reject("BATCH WRITE request failed: " + statuscode);
            }.bindenv(this));
        }.bindenv(this));
    }

    function _updateTable(updateParams) {
        return Promise(function(resolve, reject) {
            _db.action(AWS_DYNAMO_DB_ACTION_UPDATE_TABLE, updateParams, function(updateResp) {
                local statuscode = updateResp.statuscode;

                if (!_respIsSuccessful(statuscode)) {
                    local errMsg = _getRespErrMsg(resp, "UPDATE TABLE " + _tablename + " request failed. ");
                    return reject(errMsg);
                }

                return resolve("UPDATE TABLE request successful");
            }.bindenv(this));
        }.bindenv(this));
    }

    // // Helper functions
    // // --------------------------------------------------------------------

    function _onDBCleanupFail(errMsg) {
        // Setup failed. Clear DB instance, so we don't bother running any tests.
        _dbConfigured = false;
        // Return the error message
        return errMsg;
    }

    function _onBatchWriteFail(errMsg) {
        return "BATCH WRITE ITEM test failed: " + errMsg;
    }

    function _onBatchGetFail(errMsg) {
        return "BATCH GET ITEM test failed: " + errMsg;
    }

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

    function _isNotNull(item) {
        return (item != null);
    }
}

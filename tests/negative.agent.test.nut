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

@include "github:electricimp/AWSRequestV4/AWSRequestV4.class.nut"

// Enter your AWS keys here
const AWS_DYNAMO_ACCESS_KEY_ID     = "@{DYNAMO_ACCESS_KEY_ID}";
const AWS_DYNAMO_SECRET_ACCESS_KEY = "@{DYNAMO_SECRET_ACCESS_KEY}";
const AWS_DYNAMO_REGION            = "@{DYNAMO_REGION}";

// http status codes
const AWS_TEST_HTTP_RESPONSE_SUCCESS = 200;
const AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND = 300;
const AWS_TEST_HTTP_RESPONSE_FORBIDDEN = 403;
const AWS_TEST_HTTP_RESPONSE_NOT_FOUND = 404;
const AWS_TEST_HTTP_RESPONSE_BAD_REQUEST = 400;

// messages
const AWS_TEST_UPDATE_VALUE = "this is a new value";
const AWS_TEST_FAKE_TABLE_NAME = "garbage";
const AWS_TEST_FAKE_TIME = 0;

// aws response error messages
const AWS_ERROR_CONVERT_TO_STRING = "NUMBER_VALUE cannot be converted to String";
const AWS_ERROR_REOSOURCE_NOT_FOUND = "Requested resource not found";
const AWS_ERROR_PARAMETER_NOT_PRESENT = "The parameter 'TableName' is required but was not present in the request";
const AWS_ERROR_LIMIT_100 = "1 validation error detected: Value '200' at 'limit' failed to satisfy constraint: Member must have value less than or equal to 100";

// info messages
const AWS_TEST_WAITING_FOR_TABLE = "Table not created yet. Waiting 5 seconds before starting tests..."

class DynamoDBNegativeTest extends ImpTestCase {

    _db = null;
    _tablename = null;
    _KeySchema = null;
    _AttributeDefinitions = null;
    _ProvisionedThroughput = null;


    // instantiates the class (AWSDynamoDB) as _db
    // Creates a table named testTable.randNum
    function setUp() {
        // Parameters to set up categories for a table
        _KeySchema = [{
            "AttributeName": "deviceId",
            "KeyType": "HASH"
        }, {
            "AttributeName": "time",
            "KeyType": "RANGE"
        }];
        _AttributeDefinitions = [{
            "AttributeName": "deviceId",
            "AttributeType": "S"
        }, {
            "AttributeName": "time",
            "AttributeType": "S"
        }];
        _ProvisionedThroughput = {
            "ReadCapacityUnits": 5,
            "WriteCapacityUnits": 5
        };

                // class initialisation
        _db = AWSDynamoDB(AWS_DYNAMO_REGION, AWS_DYNAMO_ACCESS_KEY_ID, AWS_DYNAMO_SECRET_ACCESS_KEY);

        local params = null;

        return Promise(function (resolve, reject) {
            params = { "ExclusiveStartTableName": "testTable" };

            _db.action(AWS_DYNAMO_DB_ACTION_LIST_TABLES, params, function (response) {
                if (response.statuscode >= 200 && response.statuscode < 300) {
                    local arrayOfTableNames = http.jsondecode(response.body).TableNames;
                    local tableCount = arrayOfTableNames.len();
                    // skip DB cleaning
                    if (tableCount == 0) resolve(true);
                    else this.info("DB is cleaning...");
                    // delete all tables from DB
                    foreach(tableName in arrayOfTableNames) {
                        params = { "TableName": tableName };
                        describeAndDeleteTable(params, function (result) {
                            if (result == true) {
                                tableCount--;
                                if (tableCount <= 0) {
                                    this.info("DB cleaned successfuly");
                                    resolve(true);
                                }
                            } else {
                                server.log("error " + result);
                                reject("Error during DB clean occurred");
                            }
                        }.bindenv(this));
                    }
                } else {
                    server.log("error " + response.statuscode);
                    reject("Error during DB clean occurred");
                }
            }.bindenv(this));
        }.bindenv(this)).
            then(function (result) {
                return Promise(function (resolve, reject) {
                    local randNum = (1.0 * math.rand() / RAND_MAX) * (1000 + 1);
                    _tablename = "testTable." + randNum;
                    params = {
                        "AttributeDefinitions": _AttributeDefinitions,
                        "KeySchema": _KeySchema,
                        "ProvisionedThroughput": _ProvisionedThroughput,
                        "TableName": _tablename
                    };

                    // Create a table with random name per test testTable.randNum
                    _db.action(AWS_DYNAMO_DB_ACTION_CREATE_TABLE, params, function (res) {

                        // check status code indication successful creation
                        if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                            local describeParams = {
                                "TableName": _tablename
                            };

                            // wait for the table to finish being created
                            // important as toomany request to awd _db will cause errors
                            checkTable(describeParams, function (result) {

                                if (typeof result == "bool" && result == true) {
                                    resolve("Running @{__FILE__}");
                                } else {
                                    reject(result);
                                }
                            }.bindenv(this));
                        } else {
                            reject("Failed to create table during setup of @{__FILE__}. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                        }
                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
    }

    // To be called by the setup() method
    // waits until table is active e.g finished creating then calls cb
    function checkTable(params, cb) {

        _db.action(AWS_DYNAMO_DB_ACTION_DESCRIBE_TABLE, params, function(res) {

            if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                if (http.jsondecode(res.body).Table.TableStatus == "ACTIVE") {
                    cb(true);
                } else {
                    this.info(AWS_TEST_WAITING_FOR_TABLE);
                    imp.wakeup(5, function() {
                        checkTable(params, cb);
                    }.bindenv(this));
                }
            } else {
                local msg = "Failed to describe table during setup of @{__FILE__}. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message;
                cb(msg);
            }
        }.bindenv(this));
    }

    // Checking that putting an item in a non-existent table returns
    // a http status 400 and the correct error message reveived from aws
    function testFailPutItem() {

        local params = {
            "TableName": AWS_TEST_FAKE_TABLE_NAME,
            "Item": {
                "deviceId": {
                    "S": imp.configparams.deviceid
                },
                "time": {
                    "S": time().tostring()
                },
                "status": {
                    "BOOL": true
                }
            }
        };
        return Promise(function(resolve, reject) {

            _db.action(AWS_DYNAMO_DB_ACTION_PUT_ITEM, params, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual status: " + res.statuscode);
                    this.assertTrue(AWS_ERROR_REOSOURCE_NOT_FOUND == http.jsondecode(res.body).message, http.jsondecode(res.body).message)
                    resolve("did not put item in non existent table");
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // Checking that putting a number in as string throws an error
    // a http status 400 and the correct error message from aws
    function testFailGetItem() {
        local getParams = {
            "Key": {
                "deviceId": {
                    "S": imp.configparams.deviceid
                },
                "time": {
                    "S": AWS_TEST_FAKE_TIME
                }
            },
            "TableName": _tablename,
            "AttributesToGet": [
                "time", "status"
            ],
            "ConsistentRead": false
        };
        return Promise(function(resolve, reject) {

            _db.action(AWS_DYNAMO_DB_ACTION_GET_ITEM, getParams, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual status: " + res.statuscode);
                    this.assertTrue(http.jsondecode(res.body).Message == AWS_ERROR_CONVERT_TO_STRING)
                    resolve("did not put item in non existent table");
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // Try to update table without the tablename parameter
    function testFailUpdateTable() {
        local params = {
            "ProvisionedThroughput": {
                "ReadCapacityUnits": 6,
                "WriteCapacityUnits": 6
            }
        };
        return Promise(function(resolve, reject) {

            _db.action(AWS_DYNAMO_DB_ACTION_UPDATE_TABLE, params, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, res.statuscode)
                    this.assertTrue(http.jsondecode(res.body).message == AWS_ERROR_PARAMETER_NOT_PRESENT, http.jsondecode(res.body).message)
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // To be called by the UpdateTable method, checks when a table has finished
    // updating its contained data
    function checkTableUpdated(params, cb) {

        _db.action(AWS_DYNAMO_DB_ACTION_DESCRIBE_TABLE, params, function(res) {

            if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                if (http.jsondecode(res.body).Table.TableStatus == "ACTIVE") {
                    cb(res);
                } else {
                    this.info("table not yet updated");
                    imp.wakeup(5, function() {

                        checkTableUpdated(params, cb);
                    }.bindenv(this));
                }
            } else {
                local msg = "Failed to describe table . Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message;
                cb(msg);
            }
        }.bindenv(this));
    }

    // To be called by the delete table test, determines when deletion is complete
    function checkTableDeleted(params, cb) {

        _db.action(AWS_DYNAMO_DB_ACTION_DESCRIBE_TABLE, params, function(res) {

            if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                if (http.jsondecode(res.body).Table.TableStatus == "DELETING") {
                    this.info("table not yet updated");
                    imp.wakeup(5, function() {

                        checkTableUpdated(params, cb);
                    }.bindenv(this));

                } else {
                    reject("NOT DELETED");
                }
            } else {
                cb(res);
            }
        }.bindenv(this));
    }

    // To be called by the testDeleteTable() testing method
    function describeAndDeleteTable(params, cb) {

        _db.action(AWS_DYNAMO_DB_ACTION_DESCRIBE_TABLE, params, function(res) {

            if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                if (http.jsondecode(res.body).Table.TableStatus == "ACTIVE") {
                    _db.action(AWS_DYNAMO_DB_ACTION_DELETE_TABLE, params, function(res) {

                        if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                            cb(true);
                        } else {
                            local msg = "Failed to delete a table. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message;
                            cb(msg);
                        }
                    }.bindenv(this));
                } else {
                    this.info("Table not created yet. Waiting 5 seconds before deleting...");
                    imp.wakeup(5, function() {

                        describeAndDeleteTable(params, cb);
                    }.bindenv(this));
                }
            } else {
                local msg = "Failed to describe a table (prior to deleting). Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message;
                cb(msg);
            }
        }.bindenv(this));
    }

    // return an array of TableNames
    // Limit is maximum of 100
    function testFailListTables() {

        local params = {
            "Limit": 200
        };
        return Promise(function(resolve, reject) {

            _db.action(AWS_DYNAMO_DB_ACTION_LIST_TABLES, params, function(res) {

                try {
                    this.assertTrue(http.jsondecode(res.body).message == AWS_ERROR_LIMIT_100, http.jsondecode(res.body).message);
                    resolve("Limit of 100");
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));
    }

    // deletes the table used throughout the tests
    function tearDown() {

        return Promise(function(resolve, reject) {

            local params = {
                "TableName": _tablename
            };
            describeAndDeleteTable(params, function(result) {

                if (typeof result == "bool" && result == true) {
                    resolve("Finished testing and cleaned up after @{__FILE__}");
                } else {
                    reject("Finished testing but failed to clean up after @{__FILE__}");
                }
            }.bindenv(this));
        }.bindenv(this));
    }
}

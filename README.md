# AWSDynamoDB #

[AWS DynamoDB](https://aws.amazon.com/documentation/dynamodb) is a fully managed NoSQL database service. This library uses [AWS DynamoDB Rest API](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/Welcome.html) to provide low-level API actions for managing database tables and indexes, and for creating, reading, updating and deleting data.

**Note** The AWSDynamoDB library uses [AWSRequestV4](https://github.com/electricimp/AWSRequestV4) for all requests, so the AWSRequestV4 must also be included in your agent code.

**To add this library copy and paste the following lines to the top of your agent code:**

```squirrel
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSDynamoDB.agent.lib.nut:1.0.0"
```

## Class Usage ##

### Constructor: AWSDynamoDB(*region, accessKeyId, secretAccessKey*) ###

#### Parameters ####

| Parameter | Type | Description |
| --- | --- | --- |
| **region** | String | AWS region |
| **accessKeyId** | String | AWS access key |
| **secretAccessKey** | String | AWS secret access key |

Access keys can be generated with IAM.

#### Example ####

```squirrel
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSDynamoDB.agent.lib.nut:1.0.0"

const AWS_DYNAMO_ACCESS_KEY_ID = "YOUR_KEY_ID";
const AWS_DYNAMO_SECRET_ACCESS_KEY = "YOUR_KEY";
const AWS_DYNAMO_REGION = "YOUR_REGION";

db <- AWSDynamoDB(AWS_DYNAMO_REGION, AWS_DYNAMO_ACCESS_KEY_ID, AWS_DYNAMO_SECRET_ACCESS_KEY);
```

## Class Methods ##

### action(*actionType, actionParams, callback*) ###

This method performs a specified action (eg. get batch item) with the required parameters (*actionParams*) for the specified action type.

#### Parameters ####

| Parameter | Type | Description |
| --- | --- | --- |
| *actionType* | Constant | The type of the Amazon CloudWatch Logs action that you want to perform (see [‘Action Types’](#action-types), below) |
| *actionParams* | Table | Table of action-specific parameters (see [‘Action Types’](#action-types), below) |
| *callback* | Function | Callback function that takes one parameter: a [response table](#response-table) |

#### Response Table ####

The format of the response table general to all callback functions.

| Key | Type | Description |
| --- | --- | --- |
| *body* | String | A DynamoDB response in a function specific structure that is JSON encoded. See each action parameter response, below, for details |
| *statuscode* | Integer | An HTTP status code |
| *headers* | Table | See [‘Headers’](#headers), below |

#### Headers ####

The response table’s *headers* key is a table containing the following keys:

| Key | Type | Description |
| --- | --- | --- |
| *x-amzn-requestid* | String | An Amazon request ID |
| *content-type* | String | The content type eg. `"text/XML"` |
| *date* | String | The date and time at which the response was sent |
| *content-length* | String | The length of the content |
| *x-amz-crc32* | String | Checksum of the UTF-8 encoded bytes in the HTTP response |

## Action Types ##

| Action Type | Description |
| --- | --- |
| [*AWS_DYNAMO_DB_ACTION_BATCH_GET_ITEM*](#aws_dynamo_db_action_batch_get_item) | Returns the attributes of one or more items from one or more tables |
| [*AWS_DYNAMO_DB_ACTION_BATCH_WRITE_ITEM*](#aws_dynamo_db_action_batch_write_item) | Puts or deletes multiple items in one or more tables |
| [*AWS_DYNAMO_DB_ACTION_CREATE_TABLE*](#aws_dynamo_db_action_create_table) | Adds a new table to your account |
| [*AWS_DYNAMO_DB_ACTION_DELETE_ITEM*](#aws_dynamo_db_action_delete_item) | Deletes a single existing item |
| [*AWS_DYNAMO_DB_ACTION_DELETE_TABLE*](#aws_dynamo_db_action_delete_table) | Deletes a single existing table |
| [*AWS_DYNAMO_DB_ACTION_DESCRIBE_LIMITS*](#aws_dynamo_db_action_describe_limits) | Returns the current provisioned-capacity limits for your AWS account |
| [*AWS_DYNAMO_DB_ACTION_DESCRIBE_TABLE*](#aws_dynamo_db_action_describe_table) | Returns information about a single existing table |
| [*AWS_DYNAMO_DB_ACTION_GET_ITEM*](#aws_dynamo_db_action_get_item) | Returns a single existing item|
| [*AWS_DYNAMO_DB_ACTION_LIST_TABLES*](#aws_dynamo_db_action_list_tables) | Returns a list of table names |
| [*AWS_DYNAMO_DB_ACTION_PUT_ITEM*](#aws_dynamo_db_action_put_item) | Uploads a single item |
| [*AWS_DYNAMO_DB_ACTION_QUERY*](#aws_dynamo_db_action_query) | Initiate a database query operation |
| [*AWS_DYNAMO_DB_ACTION_SCAN*](#aws_dynamo_db_action_scan) | Returns one or more items and item attributes |
| [*AWS_DYNAMO_DB_ACTION_UPDATE_ITEM*](#aws_dynamo_db_action_update_item) | Modifies a single existing item |
| [*AWS_DYNAMO_DB_ACTION_UPDATE_TABLE*](#aws_dynamo_db_action_update_table) | Modifies a single existing table |

Specific actions of the types [listed above](#action-types) are configured by passing information into *action()*’s *actionParams* parameter as a table with the following action type-specific keys.

### AWS_DYNAMO_DB_ACTION_BATCH_GET_ITEM ###

This action returns the attributes of one or more items from one or more tables. You identify requested items by primary key. For more detail please see the
[AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchGetItem.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *RequestItems* | Table | Yes | A map of one or more table names and, for each table, a list of operations to be performed (DeleteRequest or PutRequest) |
| *ReturnConsumedCapacity* | String | No | Valid values: *INDEXES, TOTAL, NONE*.<br />*INDEXES* returns aggregate *ConsumedCapacity* for the operation, and *ConsumedCapacity* for each table and secondary index.<br />*TOTAL* returns only aggregate *ConsumedCapacity*.<br />*NONE* (default) returns no *ConsumedCapacity* details |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *ConsumedCapacity* | Array of tables | The capacity units consumed by the entire batch read operation |
| *Responses* | Table | Each object in *Responses* consists of a table name, along with a map of attribute data consisting of the data type and attribute value |
| *UnprocessedKeys* | Table | A map of tables and their respective keys that were not processed with the current response |

#### Example ####

**Note** Follows from *AWS_DYNAMO_DB_ACTION_BATCH_WRITE_ITEM* Example

```squirrel
local getParams = {
  "RequestItems": {
    "testTable2": {
      "Keys": [
          { "deviceId": {"S": imp.configparams.deviceid},
                "time": {"S": itemTime1} },
          { "deviceId": {"S": imp.configparams.deviceid},
                "time": {"S": itemTime2} }
      ]
    }
  }
};

db.action(AWS_DYNAMO_DB_ACTION_BATCH_GET_ITEM, getParams, function(response) {
  local arrayOfReturnedItems = http.jsondecode(response.body).Responses.testTable2;
})
```

### AWS_DYNAMO_DB_ACTION_BATCH_WRITE_ITEM ###

This action puts or deletes multiple items into or from one or more tables. For more detail please see the
[AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchWriteItem.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *RequestItems* | Table | Yes | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_WriteRequest.html) |
| *ReturnConsumedCapacity* | String | No | Valid values: *INDEXES, TOTAL, NONE*.<br />*INDEXES* returns aggregate *ConsumedCapacity* for the operation, and *ConsumedCapacity* for each table and secondary index.<br />*TOTAL* returns only aggregate *ConsumedCapacity*.<br />*NONE* (default) returns no *ConsumedCapacity* details |
| *ReturnItemCollectionMetrics* | String | No | Valid values: *SIZE, NONE*.<br />Determines whether item collection metrics are returned. If set to *SIZE*, the response includes statistics about item collections. If set to *NONE* (default), no statistics are returned |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *ConsumedCapacity* | Array of tables | The capacity units consumed by the entire batch write operation |
| *ItemCollectionMetrics* | Array of tables | A list of tables that were processed by the batch action and, for each table, information about any item collections that were affected by individual delete or put operations |
| *UnprocessedItems* | Array of tables | A map of tables and requests against those tables that were not processed. The value of *UnprocessedItems* is in the same form as *requestItems*, so you can provide this value directly to a subsequent batch read operation |

#### Example ####

```squirrel
// Writing to an existing table called testTable2 with key schema seen in create table
local writeParams = {
  "RequestItems": {
    "testTable2": [
      { "PutRequest": { "Item": { "deviceId": { "S": imp.configparams.deviceid },
                                  "time": { "S": itemTime1 },
                                  "batchNumber": { "N": "1" } } }
      },
      { "PutRequest": { "Item": { "deviceId": { "S": imp.configparams.deviceid },
                                  "time": { "S": itemTime2 },
                                  "batchNumber": { "N": "2" } } }
      }
    ]
  }
};

db.action(AWS_DYNAMO_DB_ACTION_BATCH_WRITE_ITEM, writeParams, function(response) {
  if (response.statuscode >= 200 && response.statuscode < 300) {
    server.log("Batch write successful");
  } else {
    server.log("Batch write unsuccessful");
  }
})
```

### AWS_DYNAMO_DB_ACTION_CREATE_TABLE ###

This action adds a new table to your account. In an AWS account, table names must be unique within each region. For more detail please see the
[AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateTable.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *AttributeDefinitions* | Array of tables | Yes | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeDefinition.html) |
| *KeySchema* | Array of tables | Yes | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_KeySchemaElement.html) |
| *ProvisionedThroughput* | Table | Yes | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ProvisionedThroughput.html) |
| *TableName* | String | Yes | The name of the table to create |
| *GlobalSecondaryIndexes* | Array of tables | No | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GlobalSecondaryIndex.html). Default: `null` |
| *LocalSecondaryIndexes* | Array of tables | No | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_LocalSecondaryIndex.html). Default: `null` |
| *StreamSpecifiation* | Table | No | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_StreamSpecification.html). Default: `null` |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *TableDescription* | Table | Represents the properties of a table (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TableDescription.html)) |

#### Example ####

```squirrel
local randNum = (1.0 * math.rand() / RAND_MAX) * 1001;
local tableName = "testTable." + randNum;
local params = {
  "AttributeDefinitions": [
      { "AttributeName": "deviceId",
        "AttributeType": "S" },
      { "AttributeName": "time",
        "AttributeType": "S" } ],
  "KeySchema": [
      { "AttributeName": "deviceId",
        "KeyType": "HASH" },
      { "AttributeName": "time",
        "KeyType": "RANGE" } ],
  "ProvisionedThroughput": { "ReadCapacityUnits": 5,
                             "WriteCapacityUnits": 5 },
  "TableName": tableName
};

db.action(AWS_DYNAMO_DB_ACTION_CREATE_TABLE, params, function(response) {
  if (response.statuscode >= 200 && response.statuscode < 300) {
    server.log("Table creation successful");
  } else {
    server.log("Table creation unsuccessful");
  }
}.bindenv(this));
```

### AWS_DYNAMO_DB_ACTION_DELETE_ITEM ###

This action deletes a single item in a table by primary key. For more detail please see the [AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteItem.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *Key* | Table | Yes | A map of attribute names to *AttributeValue* objects, representing the primary key of the item to delete |
| *TableName* | String | Yes | The name of the table from which to delete the item |
| *ConditionalExpression* | String | No | A condition that must be satisfied in order for a conditional delete action to succeed. Default: `null` |
| *ExpressionAttributeNames* | Table | No | One or more substitution tokens for attribute names in an expression. Default: `null` |
| *ExpressionAttributeValues* | Table | No | One or more values that can be substituted in an expression. Default: `null` |
| *ReturnConsumedCapacity* | String | No | Valid values: *INDEXES, TOTAL, NONE*.<br />*INDEXES* returns aggregate *ConsumedCapacity* for the operation, and *ConsumedCapacity* for each table and secondary index.<br />*TOTAL* returns only aggregate *ConsumedCapacity*.<br />*NONE* (default) returns no *ConsumedCapacity* details |
| *ReturnItemCollectionMetrics* | String | No | Valid values: *SIZE, NONE*.<br />Determines whether item collection metrics are returned. If set to *SIZE*, the response includes statistics about item collections. If set to *NONE* (default), no statistics are returned |
| *ReturnValues* | String | No | Valid values: *ALL_OLD, NONE*.<br />Use *ALL_OLD* if you want to get the item attributes as they appeared before they were deleted, else *NONE* (default) where nothing is returned |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *Attributes* | Table | The attribute values as they appeared before the PutItem operation (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html)) |
| *ConsumedCapacity* | Table | The capacity units consumed by the PutItem operation (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html)) |
| *ItemCollectionMetrics* | Table | Information about item collections, if any, that were affected by the put operation (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ItemCollectionMetrics.html)) |

#### Example ####

```squirrel
local tableName = "YOUR_TABLE_NAME";
local itemTime = time().tostring();

local deleteParams = {
  "Key": { "deviceId": { "S": imp.configparams.deviceid },
           "time": { "S": itemTime } },
  "TableName": tableName,
};

db.action(AWS_DYNAMO_DB_ACTION_DELETE_ITEM, deleteParams, function(response) {
  if (response.statuscode >= 200 && response.statuscode < 300) {
    server.log("Successfully deleted item");
  } else {
    server.log("Error: " + response.statuscode);
  }
});
```

### AWS_DYNAMO_DB_ACTION_DELETE_TABLE ###

This action deletes a single table. For more details please see the [AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteTable.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *TableName* | String | Yes | The name of the table to delete |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *TableDescription* | Table | Represents the properties of a table (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TableDescription.html)) |

#### Example ####

```squirrel
local params = { "TableName": tableName };

db.action(AWS_DYNAMO_DB_ACTION_DELETE_TABLE, params, function(response) {
  if (response.statuscode >= 200 && response.statuscode < 300) {
    server.log("Successfully deleted Table");
  } else {
    server.log("Error: " + response.statuscode);
  }
});
```

### AWS_DYNAMO_DB_ACTION_DESCRIBE_LIMITS ###

This action returns the current provisioned-capacity limits for your AWS account in a region, both for the region as a whole and for any one DynamoDB table that you create there. For more detail please see the [AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeLimits.html).

This action requires no action parameters &mdash; pass in an empty table as per the example below.

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *AccountMaxReadCapacityUnits* | Integer | The maximum total read capacity units that your account allows you to provision across all of your tables in this region |
| *AccountMaxWriteCapacityUnits* | Integer | The maximum total write capacity units that your account allows you to provision across all of your tables in this region |
| *TableMaxReadCapacityUnits* | Integer | The maximum read capacity units that your account allows you to provision for a new table that you are creating in this region, including the read capacity units provisioned for its global secondary indexes (GSIs) |
| *TableMaxWriteCapacityUnits* | Integer | The maximum write capacity units that your account allows you to provision for a new table that you are creating in this region, including the write capacity units provisioned for its global secondary indexes (GSIs) |

#### Example ####

```squirrel
db.action(AWS_DYNAMO_DB_ACTION_DESCRIBE_LIMITS, {}, function(response) {
  if (response.statuscode >= 200 && response.statuscode < 300) {
    server.log("AccountMaxReadCapacityUnits: " + http.jsondecode(response.body).AccountMaxReadCapacityUnits);
  } else {
    server.log("Error: " + response.statuscode);
  }
});
```

### AWS_DYNAMO_DB_ACTION_DESCRIBE_TABLE ###

This action returns information about the table, including the current status of the table, when it was created, the primary key schema, and any indexes on the table. For more details please see the [AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTable.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *TableName* | String | Yes | The name of the table to describe |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *Table* | Table | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TableDescription.html) |

#### Example ####

```squirrel
local tableName = "YOUR_TABLE_NAME";
local params = { "TableName": tableName };
db.action(AWS_DYNAMO_DB_ACTION_DESCRIBE_TABLE, params, function(response) {
  server.log("The name of the table described is " + http.jsondecode(response.body).Table.TableName);
});
```

### AWS_DYNAMO_DB_ACTION_GET_ITEM ###

This action returns a set of attributes for the item with the given primary key. For more details please see the [AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GetItem.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *Key* | Table | Yes | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html) |
| *TableName* | String | Yes | The name of the table containing the requested item |
| *AttributesToGet* | Array of strings | No | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.AttributesToGet.html). Default: `null` |
| *ConsistentRead* | Boolean | No | If set to `true`, then the operation uses strongly consistent reads; otherwise, the operation uses eventually consistent reads. Default: `false` |
| *ExpressionAttributeNames* | Table | No | One or more substitution tokens for attribute names in an expression. Default: `null` |
| *ProjectionExpression* | String | No | String that identifies one or more attributes to retrieve from the table. These attributes can include scalars, sets or elements of a JSON document. The attributes in the expression must be separated by commas. Default: `null` |
| *ReturnConsumedCapacity* | String | No | Valid values: *INDEXES, TOTAL, NONE*.<br />*INDEXES* returns aggregate *ConsumedCapacity* for the operation, and *ConsumedCapacity* for each table and secondary index.<br />*TOTAL* returns only aggregate *ConsumedCapacity*.<br />*NONE* (default) returns no *ConsumedCapacity* details |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *ConsumedCapacity* | Table | The capacity units consumed by the GetItem operation (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html)) |
| *Item* | Table | A map of attribute names to AttributeValue objects (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html)) |

#### Example ####

```squirrel
local tableName = "YOUR_TABLE_NAME";
local itemTime = time().tostring();
local getParams = {
  "Key": { "deviceId": { "S": imp.configparams.deviceid },
           "time": { "S": itemTime } },
  "TableName": tableName,
  "AttributesToGet": [ "time", "status" ],
  "ConsistentRead": false
};

db.action(AWS_DYNAMO_DB_ACTION_GET_ITEM, getParams, function(response) {
  server.log( "retrieved time: " + http.jsondecode(response.body).Item.time.S);
});
```

### AWS_DYNAMO_DB_ACTION_LIST_TABLES ###

This action returns an array of table names associated with the current account and endpoint. For more details please see the [AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTables.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *ExclusiveStartTableName* | String | No | The first table name that this operation will evaluate. Default: `null` |
| *Limit* | Integer | No | A maximum number of table names to return. Default: 100 |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *LastEvaluatedTableName* | String | The name of the last table in the current page of results |
| *TableNames* | Array of strings | The names of the tables associated with the current account at the current endpoint. The maximum size of this array is 100 |

#### Example ####

```squirrel
local params = { "Limit": 10 };

db.action(AWS_DYNAMO_DB_ACTION_LIST_TABLES, params, function(response) {
  if (response.statuscode >= 200 && response.statuscode < 300) {
    local arrayOfTableNames = http.jsondecode(response.body).TableNames;
  } else {
    server.log("error " + response.statuscode);
  }
});
```

### AWS_DYNAMO_DB_ACTION_PUT_ITEM ###

This action creates a new item, or replaces an old item with a new item. For more details please see the [AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *Item* | Table | Yes | A map of attribute name/value pairs, one for each attribute. Only the primary key attributes are required; you can optionally provide other attribute name-value pairs for the item |
| *TableName* | String | Yes | The name of the table to contain the item |
| *ConditionalExpression* | String | No | A condition that must be satisfied in order for a conditional put action to succeed. Default: `null` |
| *AttributesToGet* | Array of strings | No | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.AttributesToGet.html). Default: `null` |
| *ExpressionAttributeNames* | Table | No | One or more substitution tokens for attribute names in an expression. Default: `null` |
| *ExpressionAttributeValues* | Table | No | One or more values that can be substituted in an expression (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html)). Default: `null` |
| *ReturnConsumedCapacity* | String | No | Valid values: *INDEXES, TOTAL, NONE*.<br />*INDEXES* returns aggregate *ConsumedCapacity* for the operation, and *ConsumedCapacity* for each table and secondary index.<br />*TOTAL* returns only aggregate *ConsumedCapacity*.<br />*NONE* (default) returns no *ConsumedCapacity* details |
| *ReturnItemCollectionMetrics* | String | No | Valid Values: *SIZE, NONE*.<br />If set to *SIZE*, the response includes statistics about item collections. If set to *NONE* (default), no statistics are returned |
| *ReturnValues* | String | No | Valid Values: *ALL_OLD, NONE*.<br />If set to *ALL_OLD*, then if the action overwrote an attribute name-value pair, the content of the old item is returned. If set to *NONE* (default), nothing is returned |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *Attributes* | Table | The attribute values as they appeared before the PutItem operation (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html)) |
| *ConsumedCapacity* | Table | The capacity units consumed by the PutItem operation (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html)) |
| *ItemCollectionMetrics* | Table | Information about item collections, if any, that were affected by the put operation (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ItemCollectionMetrics.html)) |

#### Example ####

```squirrel
local tableName = "YOUR_TABLE_NAME";
local putParams = { "TableName": tableName,
                    "Item": { "deviceId": { "S": imp.configparams.deviceid },
                              "time": { "S": itemTime },
                              "status": { "BOOL": true } }
};

db.action(AWS_DYNAMO_DB_ACTION_PUT_ITEM, putParams, function(response) {
  if (response.statuscode == 200) {
    server.log("Successfully put in item");
  } else {
    server.log("failed to put item, error: " + response.statuscode);
  }
});
```

### AWS_DYNAMO_DB_ACTION_QUERY ###

This action is a query operation that uses the primary key of a table or a secondary index to directly access items from that table or index. For more details please see the [AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *TableName* | String | Yes | The name of the table containing the requested items |
| *AttributesToGet* | Array of strings | No | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.AttributesToGet.html). Default: `null` |
| *ConditionalOperator* | String | No | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.ConditionalOperator.html). Default: `null` |
| *ConsistentRead* | Boolean | No | If set to `true`, the operation uses strongly consistent reads; otherwise, the operation uses eventually consistent reads. Default: `false`|
| *ExclusiveStartKey* | Table | No | The primary key of the first item that this operation will evaluate. Default: `null` |
| *ExpressionAttributeNames* | Table | No | One or more substitution tokens for attribute names in an expression. Default: `null` |
| *ExpressionAttributeValues* | Table | No | One or more values that can be substituted in an expression. Default: `null` |
| *FilterExpression* | String | No | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Query.html#FilteringResults). Default: `null` |
| *IndexName* | String | No | The name of an index to query. This index can be any local secondary index or global secondary index on the table. Default: `null` |
| *KeyConditionExpression* | String | No | The condition that specifies the key value(s) for items to be retrieved by the query action. Default: `null` |
| *Limit* | Integer | No | The maximum number of items to evaluate (not necessarily the number of matching items). Default: 1 |
| *ProjectionExpression* | String | No | A string that identifies one or more attributes to retrieve from the table. Default: `null` |
| *ReturnConsumedCapacity* | String | No | Valid values: *INDEXES, TOTAL, NONE*.<br />*INDEXES* returns aggregate *ConsumedCapacity* for the operation, and *ConsumedCapacity* for each table and secondary index.<br />*TOTAL* returns only aggregate *ConsumedCapacity*.<br />*NONE* (default) returns no *ConsumedCapacity* details |
| *ScanIndexForward* | Boolean | No | Specifies the order for index traversal: if `true` (default), the traversal is performed in ascending order; if `false`, the traversal is performed in descending order |
| *Select* | String | No | The attributes to be returned in the result. You can retrieve all item attributes, specific item attributes, the count of matching items, or in the case of an index, some or all of the attributes projected into the index. Default: `null` |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *ConsumedCapacity* | Table | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html) |
| *Count* | Integer | The number of items in the response |
| *Items* | Array of Tables | An array of item attributes that match the query criteria. Each element in this array consists of an attribute name and the value for that attribute |
| *LastEvaluatedKey* | Table | The primary key of the item where the operation stopped, inclusive of the previous result set. Use this value to start a new operation, excluding this value in the new request |
| *ScannedCount* | Integer | The number of items evaluated, before any query filter is applied. A high *ScannedCount* value with few, or no, *Count* results indicates an inefficient query operation |

#### Example ####

```squirrel
local params = { "TableName": tableName,
                 "KeyConditionExpression": "deviceId = :deviceId",
                 "ExpressionAttributeValues": { ":deviceId": { "S": imp.configparams.deviceid } }
};

db.action(AWS_DYNAMO_DB_ACTION_QUERY, params, function(response) {
  if (response.statuscode >= 200 && response.statuscode < 300) {
    server.log("The time stored is: " +  http.jsondecode(response.body).Items[0].time.S);
  } else {
    server.log("error: " + response.statuscode);
  }
});
```

### AWS_DYNAMO_DB_ACTION_SCAN ###

This action returns one or more items and item attributes by accessing every item in a table or a secondary index. For more details please see the [AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Scan.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *TableName* | String | Yes | The name of the table containing the requested items; or, if you provide *IndexName*, the name of the table to which that index belongs |
| *AttributesToGet* | Array of strings | No | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.AttributesToGet.html). Default: `null` |
| *ConditionalOperator* | String | No | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.ConditionalOperator.html). Default: `null` |
| *ConsistentRead* | Boolean | No | If set to `true`, the operation uses strongly consistent reads; otherwise, the operation uses eventually consistent reads. Default: `false` |
| *ExclusiveStartKey* | Table | No | The primary key of the first item that this operation will evaluate. Default: `null` |
| *ExpressionAttributeNames* | Table | No | One or more substitution tokens for attribute names in an expression. Default: `null` |
| *ExpressionAttributeValues* | table | No | One or more values that can be substituted in an expression. Default: `null` |
| *FilterExpression* | String | No | One or more values that can be substituted in an [expression](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Query.html#FilteringResults). Default: `null` |
| *IndexName* | String | No | The name of a secondary index to scan. Default: `null` |
| *Limit* | Integer | No | The maximum number of items to evaluate (not necessarily the number of matching items). Default: 1 |
| *ProjectionExpression* | String | No | A string that identifies one or more attributes to retrieve from the table. Default: `null` |
| *ReturnConsumedCapacity* | String | No | Valid values: *INDEXES, TOTAL, NONE*.<br />*INDEXES* returns aggregate *ConsumedCapacity* for the operation, and *ConsumedCapacity* for each table and secondary index.<br />*TOTAL* returns only aggregate *ConsumedCapacity*.<br />*NONE* (default) returns no *ConsumedCapacity* details |
| *Segment* | Integer | No | For a parallel scan request, *Segment* identifies an individual segment to be scanned by an application worker. Default: `null` |
| *Select* | String | No | The attributes to be returned in the result. You can retrieve all item attributes, specific item attributes, the count of matching items, or in the case of an index, some or all of the attributes projected into the index. Default: `null` |
| *TotalSegments* | Integer | No | For a parallel scan request, *TotalSegments* represents the total number of segments into which the scan operation will be divided. Default: `null` |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *ConsumedCapacity* | Table | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html) |
| *Count* | Integer | The number of items in the response |
| *Items* | Array of Tables | An array of item attributes that match the query criteria. Each element in this array consists of an attribute name and the value for that attribute |
| *LastEvaluatedKey* | Table | The primary key of the item where the operation stopped, inclusive of the previous result set. Use this value to start a new operation, excluding this value in the new request |
| *ScannedCount* | Integer | The number of items evaluated, before any query filter is applied. A high *ScannedCount* value with few, or no, *Count* results indicates an inefficient query operation |

#### Example ####

```squirrel
local params = { "TableName": tableName, };

db.action(AWS_DYNAMO_DB_ACTION_SCAN, params, function(response) {
  if (response.statuscode >= 200 && response.statuscode < 300) {
    // Returned deviceId from scan
    // NOTE this example requires the table created in the CreateTable example
    local deviceId = http.jsondecode(response.body).Items[0].deviceId.S;
  } else {
    server.log("error: " + response.statuscode);
  }
});
```

### AWS_DYNAMO_DB_ACTION_UPDATE_ITEM ###

This action updates an existing item.For more details please see the [AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateItem.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *Key* | Table | Yes | The primary key of the item to be updated (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html)) |
| *TableName* | String | Yes | The name of the table containing the item to update |
| *AttributesUpdates* | Table | No | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.AttributeUpdates.html). Default: `null` |
| *ConditionalExpression* | String | No | A condition that must be satisfied in order for a conditional update operation to succeed. Default: `null` |
| *ExpressionAttributeNames* | Table | No | One or more substitution tokens for attribute names in an expression. Default: `null` |
| *ExpressionAttributeValues* | Table | No | One or more values that can be substituted in an expression. Default: `null` |
| *ReturnConsumedCapacity* | String | No | Valid values: *INDEXES, TOTAL, NONE*.<br />*INDEXES* returns aggregate *ConsumedCapacity* for the operation, and *ConsumedCapacity* for each table and secondary index.<br />*TOTAL* returns only aggregate *ConsumedCapacity*.<br />*NONE* (default) returns no *ConsumedCapacity* details |
| *ReturnItemCollectionMetrics* | String | No | Determines whether item collection metrics are returned. If set to *SIZE*, the response includes statistics about item collections. If set to *NONE* (default), no statistics are returned |
| *ReturnValues* | String | No | Valid values: *ALL_OLD, All_NEW, UPDATED_OLD, UPDATED_NEW, NONE*.<br />Use *ReturnValues* if you want to get the item attributes as they appeared either before or after they were updated. Use *ALL_OLD* for all attributes prior to being changed; *All_NEW* for all attributes after the change; *UPDATED_OLD* for all attributes that were changed but returns values prior to change; *UPDATED_NEW* for all attributes that were changed but returns values after the change; or *NONE* (default) to have nothing returned |
| *UpdateExpression* | String | No | An expression that defines one or more attributes to be updated, the action to be performed on them, and new value(s) for them. Default: `null` |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *Attributes* | Table | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html) |
| *ConsumedCapacity* | Table | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html) |
| *ItemCollectionMetrics* | Table | See [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ItemCollectionMetrics.html) |

#### Example ####

**NOTE** This example follows from the *AWS_DYNAMO_DB_ACTION_PUT_ITEM* example.

```squirrel
local updateParams = {
  "Key": { "deviceId": { "S": imp.configparams.deviceid },
           "time": { "S": itemTime } },
  "TableName": tableName,
  "UpdateExpression": "SET newVal = :newVal",
  "ExpressionAttributeValues": { ":newVal": {"S":"this is a new value"} },
  "ReturnValues": "UPDATED_NEW"
};

db.action(AWS_DYNAMO_DB_ACTION_UPDATE_ITEM, updateParams, function(response) {
  if (response.statuscode >= 200 && response.statuscode < 300) {
    server.log("New attribute was Successfully entered with a value: " + http.jsondecode(response.body).Attributes.newVal.S);
  } else {
    server.log("error: " + response.statuscode);
  }
});
```

### AWS_DYNAMO_DB_ACTION_UPDATE_TABLE ###

This action modifies the provisioned throughput settings, global secondary indexes, or DynamoDB Streams settings for a given table. For more details please see the [AWS DynamoDB documentation](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTable.html).

#### Parameters Table Keys ####

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| *TableName* | String | Yes | The name of the table to be updated |
| *AttributeDefinitions* | Table | No | An Array of attributes that describe the key schema for the table and indexes. Default: `null` |
| *GlobalSecondaryIndexUpdates* | Array of tables | No | An array of one or more global secondary indexes for the table (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTable.html#API_UpdateTable_RequestSyntax)). Default: `null` |
| *ProvisionedThroughput* | Table | No | The new provisioned throughput settings for the specified table or index (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ProvisionedThroughput.html)). Default: `null` |
| *StreamSpecification* | Table | No | Represents the DynamoDB Streams configuration for the table (see [here](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_StreamSpecification.html)). Default: `null` |

#### Response ####

The response table contains a key, *body*, which is a table that includes the following JSON encoded keys:

| Key | Type | Description |
| --- | --- | --- |
| *TableDescription* | Table | Represents the properties of a [table](http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TableDescription.html) |

#### Example ####

```squirrel
local params = { "TableName": _tablename,
                 "ProvisionedThroughput": { "ReadCapacityUnits": 6,
                                            "WriteCapacityUnits": 6 }
};

db.action(AWS_DYNAMO_DB_ACTION_UPDATE_TABLE, params, function(response) {
  if (response.statuscode >= 200 && response.statuscode < 300) {
    server.log("New attribute was Successfully entered with a value: " + http.jsondecode(response.body).Attributes.newVal.S);
  } else {
    server.log("error: " + response.statuscode);
  }
});
```

## License ##

The AWSDynamoDB library is licensed under the [MIT License](LICENSE).

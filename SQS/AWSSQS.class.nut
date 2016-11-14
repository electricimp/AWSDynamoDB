
// Copyright (c) 2016 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

class AWSSQS {

    static version = [1, 0, 0];

    static SERVICE = "sqs";
    static TARGET_PREFIX = "SQS_20121105";

    _awsRequest = null;

    /**
     * @param {string} region
     * @param {string} accessKeyId
     * @param {string} secretAccessKey
     */
    constructor(region, accessKeyId, secretAccessKey) {
        if ("AWSRequestV4" in getroottable()) {
            _awsRequest = AWSRequestV4(SERVICE, region, accessKeyId, secretAccessKey);
        } else {
            throw ("This class requires AWSRequestV4 - please make sure it is loaded.");
        }
    }

    /**
     * @param {table} params
     * @param {function} cb
     */
    function DeleteMessage(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "DeleteMessage",
            "Version": "2012-11-05"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    /**
     * @param {table} params
     * @param {function} cb
     */
    function DeleteMessageBatch(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "DeleteMessageBatch",
            "Version": "2012-11-05"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    /**
     * @param {table} params
     * @param {function} cb
     */
    function ReceiveMessage(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "ReceiveMessage",
            "Version": "2012-11-05"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    /**
     * @param {table} params
     * @param {function} cb
     */
    function SendMessage(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "SendMessage",
            "Version": "2012-11-05"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    /**
     * @param {table} params
     * @param {function} cb
     */
    function SendMessageBatch(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "SendMessageBatch",
            "Version": "2012-11-05"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

}


// Copyright (c) 2016 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

class AWSCloudWatchLogs {
    static version = [1, 0, 0];

    static SERVICE = "logs";
    static TARGET_PREFIX = "Logs_20140328";

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
    function CreateLogStream(params, cb) {
        local headers = { "X-Amz-Target": format("%s.CreateLogStream", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

}

class AWSLambda {

    static version = [1, 0, 0];

	static SERVICE = "lambda";
    static URL_PREFIX = "/2015-03-31/functions/";
    static TARGET_PREFIX = "Lambda_20150331";

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
    function Invoke(params, contenttype = null, cb = null) {
        if (typeof contenttype == "function" || contenttype == null) {
            cb = contenttype;
            contenttype = "application/json";
        }

        local headers = {"Content-Type": contenttype, "X-Amz-Target": format("%s.InvokeFunction", TARGET_PREFIX) };
        local body = (contenttype == "application/json") ? http.jsonencode(params.Payload) : params.Payload;
        _awsRequest.post(URL_PREFIX + params.FunctionName + "/invocations", headers, body, cb);
    }

}

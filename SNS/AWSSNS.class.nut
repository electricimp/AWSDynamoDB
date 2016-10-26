class AWSSNS {

    static version = [1, 0, 0];

    static SERVICE = "sns";
    static TARGET_PREFIX = "SNS_20100331";

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
    function ConfirmSubscription(params, cb) {
        local headers = { "X-Amz-Target": format("%s.ConfirmSubscription", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    /**
     * @param {table} params
     * @param {function} cb
     */
    function ListSubscriptions(params, cb) {
        local headers = { "X-Amz-Target": format("%s.ListSubscriptions", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    /**
     * @param {table} params
     * @param {function} cb
     */
    function ListSubscriptionsByTopic(params, cb) {
        local headers = { "X-Amz-Target": format("%s.ListSubscriptionsByTopic", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    /**
     * @param {table} params
     * @param {function} cb
     */
    function ListTopics(params, cb) {
        local headers = { "X-Amz-Target": format("%s.ListTopics", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    /**
     * @param {table} params
     * @param {function} cb
     */
    function Publish(params, cb) {
        local headers = { "X-Amz-Target": format("%s.Publish", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    /**
     * @param {table} params
     * @param {function} cb
     */
    function Subscribe(params, cb) {
        local headers = { "X-Amz-Target": format("%s.Subscribe", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    /**
     * @param {table} params
     * @param {function} cb
     */
    function Unsubscribe(params, cb) {
        local headers = { "X-Amz-Target": format("%s.Unsubscribe", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

}

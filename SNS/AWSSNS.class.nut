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
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "ConfirmSubscription",
            "Version": "2010-03-31"
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
    function ListSubscriptions(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "ListSubscriptions",
            "Version": "2010-03-31"
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
    function ListSubscriptionsByTopic(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "ListSubscriptionsByTopic",
            "Version": "2010-03-31"
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
    function ListTopics(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "ListTopics",
            "Version": "2010-03-31"
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
    function Publish(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "Publish",
            "Version": "2010-03-31"
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
    function Subscribe(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "Subscribe",
            "Version": "2010-03-31"
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
    function Unsubscribe(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "Unsubscribe",
            "Version": "2010-03-31"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

}

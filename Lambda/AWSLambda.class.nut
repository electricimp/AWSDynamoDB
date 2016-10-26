class AWSLambda {

    static version = [0, 0, 1];

	static SERVICE = "";
	static TARGET_PREFIX = "";

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

}

class AWSSES {
	static version = [1, 0, 0];

	static SERVICE = "email";
	static TARGET_PREFIX = "SES_20101201"

	_awsRequest = null;

	constructor(region, accessKeyId, secretAccessKey) {

		if ("AWSRequestV4" in getroottable()) {
			_awsRequest = AWSRequestV4(SERVICE, region, accessKeyId, secretAccessKey);
		} else {
			throw ("This class requires AWSRequestV4 - please make sure it is loaded.");
		}

	}

	//-----------------------
	function sendEmail(toAddresses, fromAddress, subject, body, cb=null) {

		local headers = { "X-Amz-Target": format("%s.SendEmail", TARGET_PREFIX) };

		local body = {
			"Destination": {
				"ToAddresses": toAddresses
			},
			"Message": {
				"Body": {
					"Text": {
						"Data": body,
					}
				},
				"Subject": {
					"Data": subject,
				}
			},
			"Source": fromAddress
		};

		_awsRequest.post("/", headers, http.jsonencode(body), cb);

	}

	// Send Raw Email
	//-----------------------
	/*
	function sendRawEmail(toAddresses, fromAddress, subject, body, extras=null, cb=null) {

		local headers = { "X-Amz-Target": format("%s.SendEmail", TARGET_PREFIX) };

		local body = {
			"Destination": {
				"ToAddresses": toAddresses
			},
			"Message": {
				"Body": {
					"Text": {
						"Data": body,
					}
				},
				"Subject": {
					"Data": subject,
				}
			},
			"Source": fromAddress
		};

		if (typeof extras == "function") {
			cb = extras;
			extras = null;
		}

		if (typeof extras == "table") {
			foreach (k,v in extras) {
				switch(k) {
					// Nested values...
					case "Destination":
					case "Message":
						foreach (k2,v2 in extras[k]) {
							body[k][k2] <- v2;
						}
					default:
						body[k] <- v;
				}
			}
		}

		_awsRequest.post("/", headers, http.jsonencode(body), cb);

	}
	*/

}

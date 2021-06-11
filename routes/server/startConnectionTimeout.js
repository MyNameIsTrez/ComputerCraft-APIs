const constants = require("../../constants");


module.exports = function (res) {

	setTimeout(() => {
		if (!res.writableEnded) { // If res.end() hasn't been called yet.
			res.end();
		}
	}, constants.httpTimeoutMs);

}

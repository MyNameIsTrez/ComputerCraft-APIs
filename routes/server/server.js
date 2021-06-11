const startConnectionTimeout = require("./startConnectionTimeout");
const printStats = require("./printStats");
const longPollFunctions = require("./longPollFunctions");


module.exports = app => {

	app.get("/never-closes", (req, res) => {
		startConnectionTimeout(res);
		console.log("never-closes called");
	});


	app.post("/server-print", (req, res) => {
		console.log("server-print: " + req.body.msg);
		res.send(true);
	});


	app.get("/is-online", (req, res) => {
		startConnectionTimeout(res);
		printStats("is-online");
		res.send(true)
	});


	app.get("/long_poll", (req, res) => {
		const fnName = req.query.fn_name;
		printStats("long_poll?fn_name=" + fnName);

		if (longPollFunctions.hasOwnProperty(fnName)) {
			longPollFunctions[fnName](res);
		} else {
			res.end("longPollFunctions doesn't contain the function '" + fnName + "'.");
		}
	});

}

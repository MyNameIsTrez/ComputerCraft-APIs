const chokidar = require("chokidar");

const constants = require("../../constants");


const chokidarOptions = {
	ignoreInitial: true,
};
const watcher = chokidar.watch("synced", chokidarOptions);


module.exports = {
	file_change: (res) => {
		setTimeout(() => {
			if (!res.writableEnded) {
				res.end();
				watcher.removeAllListeners("all");
			}
		}, constants.httpTimeoutMs);
		
		watcher.once("all", (event, path) => {
			if (!res.writableEnded) {
				res.send(true);
				console.log("Sent response.");
			}
		});
	},
}

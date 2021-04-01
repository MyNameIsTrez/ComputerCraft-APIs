const chokidar = require("chokidar");


const chokidarOptions = {
	ignoreInitial: true,
};
const watcher = chokidar.watch("synced", chokidarOptions);


// TODO: Move to globals file, as it's also in server.js
const httpTimeoutMs = 10 * 1000;


module.exports = {
	lol: (res) => {
		setTimeout(() => {
			if (!res.writableEnded) {
				res.end();
				watcher.removeAllListeners("all");
			}
		}, httpTimeoutMs);
		
		watcher.once("all", (event, path) => {
			if (!res.writableEnded) {
				res.send(true);
				console.log("Sent response.");
			}
		});
	},
}

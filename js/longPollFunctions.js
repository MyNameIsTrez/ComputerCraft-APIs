const chokidar = require("chokidar");


const chokidarOptions = {
	ignoreInitial: true,
};
const watcher = chokidar.watch("synced", chokidarOptions);


module.exports = {
	lol: function(resolve, reject) {
		watcher.on("all", (event, path) => {
			resolve(true);
		});
	},
}

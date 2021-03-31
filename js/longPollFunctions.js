const chokidar = require("chokidar");


const chokidarOptions = {
	ignoreInitial: true,
};
const watcher = chokidar.watch("synced", chokidarOptions);


module.exports={
	lol: new Promise(function(resolve, reject) {
		watcher.on("all", (event, path) => {
			console.log(event, path);
			console.log("wtf");
			resolve("works!");
		});
		console.log("wtf2");
	}),
}

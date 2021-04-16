const express = require("express");
const bodyParser = require("body-parser");
const fs = require("fs");
const path = require("path");

const app = express();


app.listen(1338, () => {
	console.log("Listening...");
});


// Fixes app.post()
// ComputerCraft versions below 1.63 don't support custom headers,
// so the content-type of those is always 'application/x-www-form-urlencoded'.
app.use(bodyParser.urlencoded({ extended: true }));


function requireAll(app) {
	const dirs = getDirectories("./routes");
	dirs.forEach(dir => {
		// Loading any file that has the same name as the parent directory.
		const p = path.join("routes", dir, dir);
		console.log(`Loaded ./${p}`);
		require("./" + p)(app);
	});
}

function getDirectories(path) {
	return fs.readdirSync(path).filter(file => {
		return fs.statSync(path+'/'+file).isDirectory();
	});
}


requireAll(app);

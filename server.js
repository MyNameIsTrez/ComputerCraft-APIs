const express = require("express");
const bodyParser = require("body-parser");
const https = require("https");
const fs = require("fs");
const path = require("path");
const read = require("fs-readdir-recursive");
const util = require("util"); // For printing circular JSON.

// Local JS files.
const longPollFunctions = require("./js/longPollFunctions");


// TODO: Move to globals file, as it's also in js/longPollFunctions.js
const httpTimeoutMs = 10 * 1000;


const app = express();

app.listen(1338, () => {
	console.log("Listening...");
});

// Fixes app.post()
// ComputerCraft versions below 1.63 don't support custom headers,
// so the content-type of those is always 'application/x-www-form-urlencoded'.
app.use(bodyParser.urlencoded({ extended: true }));


function printStats(path) {
	console.log("'" + path + "' request received on", new Date());
}


function startConnectionTimeout(res) {
	setTimeout(() => {
		if (!res.writableEnded) { // If res.end() hasn't been called yet.
			res.end();
		}
	}, httpTimeoutMs);
}


app.get("/never-closes", (req, res) => {
	startConnectionTimeout(res);
	console.log("never-closes called");
});


app.get("/is-online", (req, res) => {
	startConnectionTimeout(res);
	printStats("is-online");
	res.send(true)
});


app.get("/file", (req, res) => {
	startConnectionTimeout(res);
	const name = req.query.name;
	printStats("file?name=" + name);
	
	const file_path = path.join("synced", name + ".lua");
	if (fs.existsSync(file_path)) {
		res.download(file_path);
	} else {
		res.send(false);
	}
});


// TODO: Refactor into subfunctions.
app.post("/get-latest-files", (httpRequest, httpResponse) => {
	startConnectionTimeout(httpResponse);
	printStats("get-latest-files");
	
	const userFilesData = getUserFilesData(httpRequest.body.data);
	
	const serverFilesData = getServerFilesData();
	
	const diffFilesData = getDiffFilesData(userFilesData, serverFilesData);
	
	httpResponse.send(diffFilesData);
	
	printAddAndRemoveCounts(diffFilesData);
});


function getUserFilesData(data) {
	let msgString;
	if (data === "[]") {
		msgString = data;
	} else {
		//msgString = data.replace(/\\/g, ""); // TODO: Keep this as it may become necessary.
		msgString = data;
	}
	//console.log(msgString);
	return JSON.parse(msgString);
}


function getServerFilesData() {
	const serverFilePathsWithoutSynced = read("synced", name => {
		return name[0] !== "." && !name.endsWith(".swp");
	});
	
	let serverFilesData = {};
	
	serverFilePathsWithoutSynced.forEach(serverFilePathWithoutSynced => {
		const serverFilePath = path.join("synced", serverFilePathWithoutSynced);
		
		const stats = fs.statSync(serverFilePath);
		
		const lua_code = fs.readFileSync(serverFilePath, "utf8");
		
		const serverFileName = path.parse(serverFilePath).name;
		
		// mtime is a Date object.
		serverFilesData[serverFileName] = {
			"lua": lua_code,
			"age": stats.mtime.getTime(),
			"dir": path.parse(serverFilePathWithoutSynced).dir,
		};
	});
	
	return serverFilesData;
}


function getDiffFilesData(userFilesData, serverFilesData) {
	let diffFilesData = { "add": {}, "remove": [] };
	
	// If the user doesn't have any files yet, just send all of the server's files.
	if (Array.isArray(userFilesData) && userFilesData.length === 0) {
		diffFilesData.add = serverFilesData;
	} else {
		for (const [serverFileName, serverFileData] of Object.entries(serverFilesData)) {
			// Age is Unix time; a newer file has a larger Unix time for its modification date.
			let userFileAge;
			if (userFilesData.hasOwnProperty(serverFileName)) {
				userFileAge = userFilesData[serverFileName].age;
			}
			
			const serverFileAge = serverFileData.age;
			
			if (userFileAge === undefined || serverFileAge > userFileAge) {
				diffFilesData.add[serverFileName] = serverFileData;
			}
		}
		
		for (const userFileName in userFilesData) {
			if (!serverFilesData.hasOwnProperty(userFileName)) {
				//const removedPath = path.join(userFilesData[userFileName].dir, userFileName);
				diffFilesData.remove.push(userFileName);
			}
		}
	}
	
	return diffFilesData;
}


function printAddAndRemoveCounts(diffFilesData) {
	let changesString = "";
	
	const addedNames = Object.keys(diffFilesData.add);
	const anyAdded = addedNames.length > 0;
	if (anyAdded) {
		changesString += `Added: ${addedNames.length}`;
	}

	const removedNames = diffFilesData.remove;
	const anyRemoved = removedNames.length > 0;
	if (anyRemoved) {
		if (anyAdded) changesString += ", ";
		changesString += `Removed: ${removedNames.length}`;
	}

	if (anyAdded || anyRemoved) console.log(changesString);
}


app.get("/long_poll", (req, res) => {
	const fnName = req.query.fn_name;
	//printStats("long_poll?fn_name=" + fnName);
	
	if (longPollFunctions.hasOwnProperty(fnName)) {
		longPollFunctions[fnName](res);
	} else {
		res.end("longPollFunctions doesn't contain the function '" + fnName + "'.");
	}
});

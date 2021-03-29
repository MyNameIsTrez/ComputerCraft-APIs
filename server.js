const express = require("express");
const bodyParser = require("body-parser");
const https = require("https");
const fs = require("fs");
const path = require("path");
const read = require("fs-readdir-recursive");


const app = express();

app.listen(1338, () => {
	console.log("Listening...");
});

// Fixes app.post()
// ComputerCraft versions below 1.63 don't support custom headers,
// so the content-type of those is always 'application/x-www-form-urlencoded'.
app.use(bodyParser.urlencoded({ extended: true }));


function printStats(path) {
	console.log(path, "request received on", new Date());
}


app.get("/is-online", (req, res) => res.send(true));


app.get("/file", (req, res) => {
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
	printStats("get-latest-files");

	const data = httpRequest.body.data;
	let msgString;
	if (data === "[]") {
		msgString = data;
	} else {
		//msgString = data.slice(1, -1).replace(/\\/g, "");
		msgString = data.replace(/\\/g, "");
	}
	const userFilesData = JSON.parse(msgString);
	
	let diffFiles = { "add": {}, "remove": [] };
	
	const files = read("synced", name => {
		return name[0] !== "." && !name.endsWith(".swp");
	});
	
	const serverFilesData = {};
	
	files.forEach(serverFilePathWithoutSynced => {
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
	
	// If the user doesn't have any files yet, just send all of the server's files.
	if (Array.isArray(userFilesData) && userFilesData.length === 0) {
		diffFiles.add = serverFilesData;
	} else {
		for (const [serverFileName, serverFileData] of Object.entries(serverFilesData)) {
			// Age is Unix time; a newer file has a larger Unix time for its modification date.
			let userFileAge;
			if (userFilesData.hasOwnProperty(serverFileName)) {
				userFileAge = userFilesData[serverFileName].age;
			}
			
			const serverFileAge = serverFileData.age;
			
			if (userFileAge === undefined || serverFileAge > userFileAge) {
				diffFiles.add[serverFileName] = serverFileData;
			}
		}
		
		for (const userFileName in userFilesData) {
			if (!serverFilesData.hasOwnProperty(userFileName)) {
				console.log("removed ", userFilesData[userFileName].dir + userFileName);
				diffFiles.remove.push(userFilesData[userFileName].dir + userFileName);
			}
		}
	}
	
	const addedNames = Object.keys(diffFiles.add);
	const anyAdded = addedNames.length > 0;
	if (anyAdded) {
		console.log(`\nAdded: ${addedNames.length}`);
		console.log(JSON.stringify(addedNames));
	}

	const removedNames = diffFiles.remove;
	const anyRemoved = removedNames.length > 0;
	if (anyRemoved) {
		console.log(`\nRemoved: ${removedNames.length}`);
		console.log(JSON.stringify(removedNames));
	}

	if (anyAdded || anyRemoved) {
		console.log(`\nBytes sent: ${JSON.stringify(diffFiles).length}`);
	}

	httpResponse.send(diffFiles);
});

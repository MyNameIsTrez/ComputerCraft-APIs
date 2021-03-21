const express = require("express");
const bodyParser = require("body-parser");
const https = require("https");
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


function printStats(path) {
	console.log(path, "request received on", new Date());
}


// h=io.open("api_manager","w")h:write(http.get("http://h2896147.stratoserver.net:1338".."/api-manager-dl").readAll())h:close()
app.get("/api-manager-dl", (req, res) => {
	printStats("api-manager-dl");
	res.download("files/api_manager.lua");
});


// TODO: Refactor into subfunctions.
app.post("/apis-get-latest", (httpRequest, httpResponse) => {
	printStats("apis-get-latest");

	console.log("httpRequest.body.data:");
	console.log(httpRequest.body.data);

	const data = httpRequest.body.data;
	let msgString;
	if (data == "[]") {
		msgString = data;
	} else {
		//msgString = data.slice(1, -1).replace(/\\/g, "");
		msgString = data.replace(/\\/g, "");
	}
	console.log("msgString:", msgString);
	const userAPIs = JSON.parse(msgString);
	
	//console.log(typeof(userAPIs));
	//console.log(userAPIs["matrix"]);
	
	console.log("userAPIs key length:", Object.keys(userAPIs).length);
	
	console.log("userAPIs:")
	console.log(userAPIs);

	let diffAPIs = {};
	
	fs.readdir("apis", (err, serverAPINames) => {
		const serverAPIsData = {};
		serverAPINames.forEach(serverAPIBase => { // Base means name + extension, so foo.lua
			const APIPath = path.join("apis", serverAPIBase);
			const stats = fs.statSync(APIPath);
			
			const lua_code = fs.readFileSync(APIPath, "utf8");
			
			const serverAPIName = path.parse(serverAPIBase).name; // Trims .lua
			
			serverAPIsData[serverAPIName] = { "age": stats.mtime, "lua": lua_code};
		});

		// If the user doesn't have any APIs yet, just send all of the server's API data.
		if (Array.isArray(userAPIs) && userAPIs.length === 0) {
			diffAPIs = serverAPIsData;
		} else {
	  		for (const [serverAPIName, serverAPIData] of Object.entries(serverAPIsData)) {
				// Age is Unix time; a newer file has a larger Unix time for its modification date.
				let userAPIAge;
				if (userAPIs.hasOwnProperty(serverAPIName)) {
					userAPIAge = userAPIs[serverAPIName].age;
				}
				
				const serverAPIAge = serverAPIData.age;
	
				if (userAPIAge === undefined || serverAPIAge > userAPIAge) {
					diffAPIs[serverAPIName] = serverAPIData;
				}
	  		}
		}

		console.log("diffAPIs key count:", Object.keys(diffAPIs).length);
		console.log("diffAPIs type:", diffAPIs);
		httpResponse.send(diffAPIs);
	});
});

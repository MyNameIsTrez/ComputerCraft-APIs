const express = require("express");
const bodyParser = require("body-parser");
const https = require("https");


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


app.post("/apis-get-latest", (httpRequest, httpResponse) => {
	printStats("apis-get-latest");
	console.log(JSON.parse(httpRequest.body.data))
	httpResponse.end();
});

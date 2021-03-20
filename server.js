const express = require("express");
const bodyParser = require("body-parser");
const https = require("https");

// TEMP
//const fs = require("fs");


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


// h=io.open("apis","w")h:write(http.get("http://h2896147.stratoserver.net:1338".."/apis-download").readAll())h:close()
app.get("/apis-download", (req, res) => {
	printStats("apis-download");
	res.download("files/apis.lua");
});


app.post("/apis-get-latest", (httpRequest, httpResponse) => {
	printStats("apis-get-latest");
	console.log(JSON.parse(httpRequest.body.data))
	//console.log(httpRequest.body.data)
	//fs.writeFileSync("request_obj.json", JSON.safeStringify(httpRequest));
	httpResponse.end();
});


/*
// safely handles circular references
JSON.safeStringify = (obj, indent = 2) => {
  let cache = [];
  const retVal = JSON.stringify(
    obj,
    (key, value) =>
      typeof value === "object" && value !== null
        ? cache.includes(value)
          ? undefined // Duplicate reference found, discard key
          : cache.push(value) && value // Store value in our collection
        : value,
    indent
  );
  cache = null;
  return retVal;
};
*/

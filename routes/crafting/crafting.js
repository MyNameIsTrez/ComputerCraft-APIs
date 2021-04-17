const startConnectionTimeout = require("../server/startConnectionTimeout");


module.exports = app => {


app.get("/get-items", (req, res) => {
	startConnectionTimeout(res);
	res.download("./routes/crafting/items.json")
});


}

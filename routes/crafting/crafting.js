const { format, parse } = require("lua-json");
const fs = require("fs");

const startConnectionTimeout = require("../server/startConnectionTimeout");
const printStats = require("../server/printStats");


module.exports = app => {


app.post("/add-recipe", (req, res) => {
	startConnectionTimeout(res);
	printStats("add-recipe?recipe=" + ""); // TODO: Print recipe name.
	
	readItems()
	.then(items => {
		console.log("will add recipe");
		const recipe_obj = JSON.parse(req.body.recipe);
		const item_name = Object.keys(recipe_obj)[0];
		const recipe = recipe_obj[item_name];
		
		return addRecipe(items, item_name, recipe);
	})
	.then(items => {
		//console.log(items);
		console.log("will start writing items");
		return writeItems(items);
	})
	.then(foo => {
		console.log("sent true response");
		res.send(true);
	})
	.catch(err => {
		console.trace(err);
		res.send(false);
	});
});


}


function readItems() {
	return new Promise((resolve, reject) => {
		// TODO: Remove "utf8"?
		console.log("will start reading items.lua");
		fs.readFile("synced/jobs/items.lua", "utf8", (err, itemsLuaStr) => {
			if (err) {
				reject(err);
			}
			console.log("have read items.lua -> json");
			resolve(parse("return " + itemsLuaStr));
		});
	});
}


function addRecipe(items, item_name, recipe) {
	return new Promise((resolve, reject) => {
		console.log(item_name, recipe);
		items[item_name].recipe = recipe;
		resolve(items);
	});
}


function writeItems(itemsJSON) {
	return new Promise((resolve, reject) => {
		// .substring(6) removes "return" that's automatically prepended.
		const itemsLua = format(itemsJSON, { spaces: 0 }).substring(6);
		fs.writeFile("synced/jobs/items.lua", itemsLua, err => {
			if (err) {
				reject(err);
			}
			console.log("written items.lua");
			resolve();
		});
	});
}

const { format, parse } = require("lua-json");
const fs = require("fs");

const startConnectionTimeout = require("../server/startConnectionTimeout");
const printStats = require("../server/printStats");


module.exports = app => {


app.post("/add-recipe", (req, res) => {
	startConnectionTimeout(res);
	printStats("add-recipe?recipe_info="); // TODO: Is the recipe_info query part necessary?
	
	readItems()
	.then(items => {
		const recipeInfo = JSON.parse(req.body.recipe_info);
		return addRecipe(items, recipeInfo);
	})
	.then(items => {
		return writeItems(items);
	})
	.then(foo => {
		res.send(true);
	})
	.catch(err => {
		console.trace(err);
		res.send(false);
	});
});


app.post("/remove-recipe", (req, res) => {
	startConnectionTimeout(res);
	const item = req.body.item;
	printStats("remove-recipe?item=" + item);
	
	readItems()
	.then(items => {
		return removeRecipe(items, item);
	})
	.then(items => {
		return writeItems(items);
	})
	.then(foo => {
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
		fs.readFile("synced/data/items.lua", "utf8", (err, itemsLuaStr) => {
			if (err) {
				reject(err);
			}
			resolve(parse("return " + itemsLuaStr));
		});
	});
}


function addRecipe(items, recipeInfo) {
	return new Promise((resolve, reject) => {
		const craft = recipeInfo.craft;
		const recipe = recipeInfo.recipe;
		const craftCount = recipeInfo.craft_count;
		
		items[craft].recipe_info = {
			recipe,
			craft_count: craftCount
		};
		
		resolve(items);
	});
}


function removeRecipe(items, item) {
	return new Promise((resolve, reject) => {
		delete items[item].recipe_info;
		resolve(items);
	});
}


function writeItems(itemsJSON) {
	return new Promise((resolve, reject) => {
		// .substring(6) removes "return" that's automatically prepended.
		const itemsLua = format(itemsJSON, { spaces: 0 }).substring(6);
		
		fs.writeFile("synced/data/items.lua", itemsLua, err => {
			if (err) {
				reject(err);
			}
			resolve();
		});
	});
}

const csv = require("csv-parser")
const fs = require("fs")
const Database = require("nedb")
const path = require("path")


const nedb_filepath = path.join("../synced/extra", "items.db")
const csv_filepath = "Every item in Tekkit Classic - Data.csv"

const db = new Database({
	filename: nedb_filepath,
	autoload: true,
})

init_db_if_empty()


function init_db_if_empty() {
	// Counts all documents in the datastore.
	db.count({}, function (err, count) {
		console.log(count)
		if (count === 0) {
			// Initialize the database with the csv's data
			const csv_items = []
			fs.createReadStream(csv_filepath)
				.pipe(csv())
				.on("data", row => csv_items.push(row))
				.on("end", () => {
					const items = cleanup_csv_items(csv_items)
					db.insert(items, (err, new_doc) => {
						if (err) {
							throw err
						}
					})
				})
		}
	})
}


function cleanup_csv_items(csv_items) {
	const items = []
	
	Object.values(csv_items).forEach(csv_item => {
		const csv_id = csv_item["ID"]
		
		if (csv_id === "") return;
		
		const csv_name = csv_item["Name"]
		const csv_common_name = csv_item["Common Name"]
		const name = csv_common_name !== "NaN" ? csv_common_name : csv_name
		
		const csv_data_value = csv_item["Data Value"]
		const id = csv_data_value !== "NaN" ? parseFloat(csv_id + "." + csv_data_value) : parseFloat(csv_id)
		
		const csv_emc = csv_item["EMC"]
		const emc = csv_emc !== "NaN" ? parseInt(csv_emc) : null
		
		const obtainable = csv_item["Obtainable"] === "y"
		
		const csv_lore = csv_item["Lore"]
		const lore = csv_lore !== "NaN" ? csv_lore : null
		
		const csv_potion_duration = csv_item["Potion Duration"]
		const potion_duration = csv_potion_duration !== "NaN" ? parseInt(csv_potion_duration) : null
		
		const vanilla = csv_item["Vanilla"] === "y"
		
		// TODO: Fill in these values in the spreadsheet.
		//const stack_size = csv_item["Stack Size"]
		
		//const csv_durability = csv_item["Durability"]
		//const durability = csv_durability !== "NaN" ? csv_durability : null
		
		const microblockable = csv_item["Microblockable"] === "y"
		
		items.push({
			"name": replace_periods(name), // nedb fields can't contain a "."
			id, emc, obtainable, lore,
			potion_duration, vanilla,
			//stack_size, durability,
			microblockable,
		})
	})
	
	return items
}


function replace_periods(str) {
	return str.replace(/\./g, "_")
}


function add_recipe() {
	
}

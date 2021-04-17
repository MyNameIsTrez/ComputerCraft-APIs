import csv, luadata


def add_item(rows, items):
    #print(rows)

    csv_id = rows["ID"]

    if(csv_id != ""):
        csv_name = rows["Name"]
        csv_common_name = rows["Common Name"]
        name = csv_common_name if csv_common_name != "NaN" else csv_name

        csv_data_value = rows["Data Value"]
        id_ = float(csv_id + "." + csv_data_value) if csv_data_value != "NaN" else float(csv_id + ".0")

        csv_emc = rows["EMC"]
        emc = int(csv_emc) if csv_emc != "NaN" else False

        obtainable = rows["Obtainable"] == "y"

        csv_lore = rows["Lore"]
        lore = csv_lore if csv_lore != "NaN" else False

        csv_potion_duration = rows["Potion Duration"]
        potion_duration = int(csv_potion_duration) if csv_potion_duration != "NaN" else False

        vanilla = rows["Vanilla"] == "y"

        # TODO: Fill in these values in the spreadsheet.
        #stack_size = rows["Stack Size"]

        # TODO: Fill in these values in the spreadsheet.
        #csv_durability = rows["Durability"]
        #durability = csv_durability if csv_durability != "NaN" else False

        microblockable = rows["Microblockable"] == "y"

        items[name] = {
            "id": id_,
            "emc": emc,
            "obtainable": obtainable,
            "lore": lore,
            "potion_duration": potion_duration,
            "vanilla": vanilla,
            #"stack_size": stack_size,
            #"durability": durability,
            "microblockable": microblockable,
        }


if __name__ == "__main__":
    csv_filepath = "Every item in Tekkit Classic - Data.csv"
    lua_filepath = "items.lua"


    items = {}

    with open(csv_filepath) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for rows in csv_reader:
            add_item(rows, items)
    
    # prefix="" circumvents the default "Return " prefix.
    luadata.write(lua_filepath, items, encoding="utf-8", prefix="")
    #luadata.write(lua_filepath, items, encoding="utf-8", indent="\t", prefix="")

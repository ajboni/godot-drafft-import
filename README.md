# Godot Drafft Import

This project provide a class to parse  [drafft](https://drafft.aboni.dev) export and a sample project showing some ways to interact with it.

It uses the wonderful [Golden Gadget](https://monnef.gitlab.io/golden-gadget/) library to do queries.

## Usage in your project

1. Download or clone the repo. 
2. Copy `drafft` folder into your project folder.
3. Parse the database:
    ```
   	var dbPath = "res://drafft_export.json"
	var db = DrafftImporter.new(dbPath)
	```
4. Interact:
	```
	# Get Item by ID
	var specificScript = db.findItemById("scripts", "378bc60a-87de-4362-aa63-c858eda00490")
	print("Script with id 378... is called %s" % specificScript.name)
	```

More examples at [drafft/example.gd](drafft/example.gd)

## Contribute

Contributions are really welcomed, we could benefit from:

* A bigger data source.
* More examples.
* More utility functions.
* A basic dialogue system.

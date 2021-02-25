extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var dbPath = "res://drafft_export.json"

	var db = DrafftImporter.new(dbPath)

	# Get the second script
	print(db.contents.scripts[1]._id)
	# Get project meta data
	print(db.contents.projectSettings.projectName)
	# Get all dialogue available properties
	print(db.contents.dialogues[0].keys())

	# Get an Item by field value	
	var houseScript = db.filterByFieldValue("scripts", "prefix", "house", true)
	print(houseScript.content.substr(0, 50))

	# Get several items by field value	
	var itemsWithMessageIcons: Array = db.filterByFieldValue("scripts", "icon", "file", false)
	print("There are %s items with file icon" % itemsWithMessageIcons.size())

	# Get Item by ID
	var specificScript = db.findItemById("scripts", "378bc60a-87de-4362-aa63-c858eda00490")
	print("Script with id 378... is called %s" % specificScript.name)

	# Custom search using Golden Gadget
	# https://monnef.gitlab.io/golden-gadget/
	var longScripts = GGArray.new(db.contents.scripts).find_or_null("x => x._id.length() > 30")
	print("There are %s Scripts with more than 30 characters" % longScripts.size())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

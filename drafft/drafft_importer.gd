class_name DrafftImporter

var contents: Dictionary


# Load a Drafft JSON database.
func _init(filePath):
	contents = _importDrafftFile(filePath)
	pass


# Get an item by its database id
func findItemById(collection, id):
	var col: GGArray = GGArray.new(contents[collection.to_lower()])
	var result = col.find_or_null("x=> x._id == '%s'" % id)
	return result


# Get a script by its prefix
func getScriptByPrefix(id):
	var col: GGArray = GGArray.new(contents.scripts)
	var result = col.find_or_null("x=> x.prefix == '%s'" % id)
	return result


# Get a dialogue by its prefix
func getDialogueByPrefix(id):
	var col: GGArray = GGArray.new(contents.dialogues)
	var result = col.find_or_null("x=> x.prefix == '%s'" % id)
	return result


# Returns item(s) where a value match for a given field.
func filterByFieldValue(collection, field, value, firstOnly = false):
	var col: GGArray = GGArray.new(contents[collection.to_lower()])
	var result: GGArray = col.filter_by_fld_val(field, value)
	if firstOnly && ! result.is_empty:
		return result.head_or_null()
	return result.val


# func findItemBy(colle)


# Import the Drafft JSON file
func _importDrafftFile(file):
	if ! file:
		print("::DRAFFT:: No Database specified. Aborting...")
		return
	var _content: String = _loadFile(file)
	var _jsonContent: JSONParseResult = _parseJSON(_content)
	var _jsonResult: Dictionary = _jsonContent.result
	if _jsonResult == null:
		print("::DRAFFT_IMPORTER:: Aborting import process. ")
		return
	return _jsonResult


# Import the Drafft JSON file
func _loadFile(fileToLoad):
	var file: File = File.new()
	if ! file.file_exists(fileToLoad):
		print("::DRAFFT_IMPORTER:: Cannot find file. " + fileToLoad)
		return
	file.open(fileToLoad, File.READ)
	var _content = file.get_as_text()
	file.close()
	return _content


#  Parse a JSON file and return the result
func _parseJSON(json):
	var _json_result: JSONParseResult = JSON.parse(json)
	if _json_result.error != OK:
		print("::DRAFFT_IMPORTER:: Error parsing JSON (but file loaded ok)")
		return null
	return _json_result

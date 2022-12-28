tool
extends DataTable
class_name PlayerTable

func _get_schema():
	return [ SchemaColumn.new("name", TYPE_STRING, ""), SchemaColumn.new("prefab", TYPE_OBJECT, null) ];

tool
extends DataTable
class_name LevelTable

func _get_schema():
	return [ SchemaColumn.new("level", TYPE_INT, 1), SchemaColumn.new("xp to level", TYPE_INT, 0), SchemaColumn.new("extra hp", TYPE_INT, 0), SchemaColumn.new("achievement icon", TYPE_OBJECT, null) ];

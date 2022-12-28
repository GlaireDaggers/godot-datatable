extends EditorInspectorPlugin

var TableEditor = preload("res://addons/datatable/editor/tableeditor.gd");

var schema: Array = [];
var plugin: EditorPlugin;

func _init(plugin: EditorPlugin):
	self.plugin = plugin;

func can_handle(object):
	return object is DataTable;
	
func parse_begin(object):
	schema = (object as DataTable)._get_schema();
	
func parse_property(object, type, path, hint, hint_text, usage):
	if path == "tableData":
		add_property_editor(path, TableEditor.new(schema, plugin));
		return true;
	return false;

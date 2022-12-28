tool
extends EditorPlugin

var tableInspectorPlugin;

func _enter_tree():
	tableInspectorPlugin = preload("res://addons/datatable/editor/tableinspectorplugin.gd").new(self);
	add_inspector_plugin(tableInspectorPlugin);

func _exit_tree():
	remove_inspector_plugin(tableInspectorPlugin);

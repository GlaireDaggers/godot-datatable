extends EditorProperty

var plugin: EditorPlugin;
var tableSchema: Array;
var addBtn: Button = Button.new();
var rowCount: Label = Label.new();
var tableroot: VBoxContainer = VBoxContainer.new();
var tablegrid: GridContainer = GridContainer.new();
var tablechildren: Array = [];

func _init(schema: Array, plugin: EditorPlugin):
	self.plugin = plugin;
	
	var gui = plugin.get_editor_interface().get_base_control();
	var addIcon = gui.get_icon("Add", "EditorIcons");
	
	tableSchema = schema;
	addBtn.icon = addIcon;
	addBtn.connect("pressed", self, "_add_pressed");
	add_child(tableroot);
	
	var hdr = HBoxContainer.new();
	tableroot.add_child(hdr);
	hdr.add_child(rowCount);
	rowCount.size_flags_horizontal |= SIZE_EXPAND;
	hdr.add_child(addBtn);
	
	tablegrid.size_flags_horizontal |= SIZE_EXPAND;
	tablegrid.columns = tableSchema.size() + 1;
	tableroot.add_child(tablegrid);
	
	for column in tableSchema:
		var columnhdr := Label.new();
		columnhdr.text = column.name;
		columnhdr.size_flags_horizontal |= SIZE_EXPAND;
		tablegrid.add_child(columnhdr);
		
	var deletehdr := Control.new();
	tablegrid.add_child(deletehdr);
	
	set_bottom_editor(tableroot);
	
func _add_pressed():
	var row: Array = [];
	for column in tableSchema:
		row.append(column.default);
	var tableData = get_edited_object().get(get_edited_property());
	tableData.append(row);
	emit_changed(get_edited_property(), tableData);
	pass;
	
# Ensure that existing table rows conform to the schema (in case it changes)
# NOTE: this is lossy - changing the schema may result in data being lost
func _conform_row(row: Array):
	if row.size() < tableSchema.size():
		# new columns added to the schema, append new defaults to row:
		for i in range(row.size(), tableSchema.size()):
			row.append(tableSchema[i].default);
	elif row.size() > tableSchema.size():
		# columns removed from schema, truncate row:
		row.resize(tableSchema.size());
	
	for columnidx in range(0, row.size()):
		var column = row[columnidx];
		var schema = tableSchema[columnidx];
		# if data type stored does not match schema, erase and replace with default
		if typeof(column) != schema.type:
			row[columnidx] = schema.default;
	
func _refresh_controls():
	var tableData = get_edited_object().get(get_edited_property());
	rowCount.text = "Rows: %d" % [tableData.size()];
	
	for item in tablechildren:
		item.queue_free();
		
	tablechildren.clear();
		
	for rowidx in range(0, tableData.size()):
		var row = tableData[rowidx];
		_conform_row(row);
		for columnidx in range(0, row.size()):
			var column = row[columnidx];
			var columnSchema = tableSchema[columnidx];
			if columnSchema.type == TYPE_INT:
				# create spinner to edit this column
				var prop := SpinBox.new();
				prop.min_value = -(1 << 31);
				prop.max_value = (1 << 31) - 1;
				prop.value = column;
				prop.step = 1;
				prop.connect("value_changed", self, "_on_value_changed_int", [row, columnidx]);
				prop.size_flags_horizontal |= SIZE_EXPAND;
				tablegrid.add_child(prop);
				tablechildren.append(prop);
			elif columnSchema.type == TYPE_REAL:
				# create field to edit this column
				var prop := SpinBox.new();
				prop.min_value = -(1 << 31);
				prop.max_value = (1 << 31) - 1;
				prop.value = column;
				prop.connect("value_changed", self, "_on_value_changed_generic", [row, columnidx]);
				prop.size_flags_horizontal |= SIZE_EXPAND;
				tablegrid.add_child(prop);
				tablechildren.append(prop);
			elif columnSchema.type == TYPE_STRING:
				var prop := LineEdit.new();
				prop.text = column;
				prop.connect("text_changed", self, "_on_value_changed_generic", [row, columnidx]);
				prop.size_flags_horizontal |= SIZE_EXPAND;
				tablegrid.add_child(prop);
				tablechildren.append(prop);
			elif columnSchema.type == TYPE_BOOL:
				var prop := CheckBox.new();
				prop.pressed = column;
				prop.connect("toggled", self, "_on_value_changed_generic", [row, columnidx]);
				prop.size_flags_horizontal |= SIZE_EXPAND;
				tablegrid.add_child(prop);
				tablechildren.append(prop);
			elif columnSchema.type == TYPE_OBJECT:
				var prop := EditorResourcePicker.new();
				prop.edited_resource = column;
				prop.connect("resource_changed", self, "_on_value_changed_resource", [row, columnidx]);
				prop.size_flags_horizontal |= SIZE_EXPAND;
				tablegrid.add_child(prop);
				tablechildren.append(prop);
			else:
				var prop := Label.new();
				prop.text = "<unsupported type>";
				prop.size_flags_horizontal |= SIZE_EXPAND;
				tablegrid.add_child(prop);
				tablechildren.append(prop);
		# add delete button as last column
		var gui = plugin.get_editor_interface().get_base_control();
		var trashIcon = gui.get_icon("Remove", "EditorIcons");
		var deleteBtn := Button.new();
		deleteBtn.icon = trashIcon;
		deleteBtn.connect("pressed", self, "_on_delete_row_pressed", [rowidx]);
		tablegrid.add_child(deleteBtn);
		tablechildren.append(deleteBtn);
	
func _on_value_changed_int(value, row, column):
	row[column] = int(value);
	var tableData = get_edited_object().get(get_edited_property());
	emit_changed(get_edited_property(), tableData, "", true);
	
func _on_value_changed_generic(value, row, column):
	row[column] = value;
	var tableData = get_edited_object().get(get_edited_property());
	emit_changed(get_edited_property(), tableData, "", true);
	
func _on_value_changed_resource(value, row, column):
	row[column] = value;
	var tableData = get_edited_object().get(get_edited_property());
	emit_changed(get_edited_property(), tableData, "", true);
	
func _on_delete_row_pressed(rowidx):
	var tableData = get_edited_object().get(get_edited_property());
	tableData.remove(rowidx);
	emit_changed(get_edited_property(), tableData);
	
func update_property():
	_refresh_controls();

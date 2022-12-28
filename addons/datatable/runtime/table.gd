tool
extends Resource
class_name DataTable

# Helper class for searching the contents of a Table
class TableSearch:
	var _table: DataTable
	var _results: Array
	
	func _init(table: DataTable, results: Array = []):
		self._table = table;
		self._results = results;
		
	func equal(column_name: String, column_value) -> TableSearch:
		var filterResults := [];
		var columnidx = _table.get_column_index(column_name);
		assert(columnidx != -1, "Column name not found in table schema");
		
		for row in _results:
			if row[columnidx] == column_value:
				filterResults.append(row);
				
		return TableSearch.new(_table, filterResults);
		
	func not_equal(column_name: String, column_value) -> TableSearch:
		var filterResults := [];
		var columnidx = _table.get_column_index(column_name);
		assert(columnidx != -1, "Column name not found in table schema");
		
		for row in _results:
			if row[columnidx] != column_value:
				filterResults.append(row);
				
		return TableSearch.new(_table, filterResults);
		
	func greater(column_name: String, column_value) -> TableSearch:
		var filterResults := [];
		var columnidx = _table.get_column_index(column_name);
		assert(columnidx != -1, "Column name not found in table schema");
		
		for row in _results:
			if row[columnidx] > column_value:
				filterResults.append(row);
				
		return TableSearch.new(_table, filterResults);
		
	func less_than(column_name: String, column_value) -> TableSearch:
		var filterResults := [];
		var columnidx = _table.get_column_index(column_name);
		assert(columnidx != -1, "Column name not found in table schema");
		
		for row in _results:
			if row[columnidx] < column_value:
				filterResults.append(row);
				
		return TableSearch.new(_table, filterResults);
		
	func greater_or_equal(column_name: String, column_value) -> TableSearch:
		var filterResults := [];
		var columnidx = _table.get_column_index(column_name);
		assert(columnidx != -1, "Column name not found in table schema");
		
		for row in _results:
			if row[columnidx] >= column_value:
				filterResults.append(row);
				
		return TableSearch.new(_table, filterResults);
		
	func less_than_or_equal(column_name: String, column_value) -> TableSearch:
		var filterResults := [];
		var columnidx = _table.get_column_index(column_name);
		assert(columnidx != -1, "Column name not found in table schema");
		
		for row in _results:
			if row[columnidx] <= column_value:
				filterResults.append(row);
				
		return TableSearch.new(_table, filterResults);
		
	# Return the number of results in this search
	func count() -> int:
		return _results.size();
		
	# Fetch the value of column by results index & column name
	func get_column_value(result_index: int, column_name: String):
		assert(result_index > 0 and result_index < _results.size(), "Result index out of range");
		var columnidx = _table.get_column_index(column_name);
		assert(columnidx != -1, "Column name not found in table schema");
		return _results[result_index][columnidx];

class SchemaColumn:
	var name: String
	var type: int
	var default
	
	func _init(name: String, type: int, default):
		self.name = name;
		self.type = type;
		self.default = default;

# Table is stored as array-of-arrays - outer array contains rows, each row is array of column data
export var tableData: Array;

# Tables should override this to return an array of SchemaColumn
func _get_schema() -> Array:
	return [];

# Get the number of rows in the table
func count() -> int:
	return tableData.size();
	
# Get the row by index
func get_row_by_index(index: int) -> Array:
	assert(index > 0 and index < tableData.size(), "Index out of range");
	return tableData[index];
	
# Get index of column matching given name
func get_column_index(column_name: String) -> int:
	var schema = _get_schema();
	for columnidx in range(0, schema.size()):
		var column = schema[columnidx];
		if column.name == column_name:
			return columnidx;
	return -1;

# Create a new TableSearch for searching this table
func create_search() -> TableSearch:
	var search = TableSearch.new(self);
	search._results = tableData;
	return search;

# Fetch the value of column by row index & column name
func get_column_value(row_index: int, column_name: String):
	assert(row_index > 0 and row_index < tableData.size(), "Row index out of range");
	var columnidx = get_column_index(column_name);
	assert(columnidx != -1, "Column name not found in table schema");
	return tableData[row_index][columnidx];

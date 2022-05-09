# :nodoc:
class SQLite3::ResultSet
  record Column, type : SQLite3::Type, name : String, length : Int32 = -1

  getter column_index
  @columns : Array(Column)?

  def current_column
    columns[column_index]
  end

  def current_column_name
    column_name(column_index)
  end

  def columns
    @columns ||= column_count.times.map do |index|
      Column.new(LibSQLite3.column_type(self, index), column_name(index))
    end.to_a
  end

  def read(t : JSON::Any.class) : JSON::Any
    JSON.parse(read(String))
  end

  def read(type : JSON::Any?.class) : JSON::Any?
    value = read(String?)
    value && JSON.parse(value)
  end
end

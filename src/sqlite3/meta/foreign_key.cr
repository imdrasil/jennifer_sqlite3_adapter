module Jennifer
  module SQLite3
    # :nodoc:
    class ForeignKey
      getter column : String, primary_key : String, to_table : String, on_update : String?, on_delete : String?

      def initialize(rs)
        id = rs.read(Int32)
        index = rs.read(Int32)
        @to_table = rs.read(String)
        @column = rs.read(String)
        @primary_key = rs.read(String)
        @on_delete = rs.read(String)
        @on_update = rs.read(String)
        match = rs.read(String)
      end

      def initialize(@to_table, @column, @primary_key, *, @on_update = nil, @on_delete = nil)
      end
    end
  end
end

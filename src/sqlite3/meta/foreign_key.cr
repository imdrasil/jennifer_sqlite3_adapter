module Jennifer
  module SQLite3
    # :nodoc:
    class ForeignKey
      getter column : String,
        primary_key : String,
        to_table : String,
        on_update : Jennifer::Adapter::SchemaProcessor::FkEventActions,
        on_delete : Jennifer::Adapter::SchemaProcessor::FkEventActions

      def initialize(rs)
        rs.read(Int32) # id
        rs.read(Int32) # index
        @to_table = rs.read(String)
        @column = rs.read(String)
        @primary_key = rs.read(String)
        @on_update = Jennifer::Adapter::SchemaProcessor::FkEventActions.parse(rs.read(String))
        @on_delete = Jennifer::Adapter::SchemaProcessor::FkEventActions.parse(rs.read(String))
        rs.read(String) # match
      end

      def initialize(@to_table, @column, @primary_key, @on_update, @on_delete)
      end

      def initialize(to_table, column, primary_key, on_update : String | Symbol, on_delete : String | Symbol)
        initialize(
          to_table,
          column,
          primary_key,
          Jennifer::Adapter::SchemaProcessor::FkEventActions.parse(on_update.to_s),
          Jennifer::Adapter::SchemaProcessor::FkEventActions.parse(on_delete.to_s)
        )
      end
    end
  end
end

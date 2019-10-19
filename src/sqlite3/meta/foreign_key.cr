module Jennifer
  module SQLite3
    # :nodoc:
    class ForeignKey
      getter column : String, primary_key : String, to_table : String, on_update : Symbol, on_delete : Symbol

      def initialize(rs)
        id = rs.read(Int32)
        index = rs.read(Int32)
        @to_table = rs.read(String)
        @column = rs.read(String)
        @primary_key = rs.read(String)
        @on_update = decode_action_name(rs.read(String))
        @on_delete = decode_action_name(rs.read(String))
        match = rs.read(String)
      end

      def initialize(@to_table, @column, @primary_key, @on_update, @on_delete)
      end

      private def decode_action_name(value)
        ::Jennifer::Adapter::SchemaProcessor::ON_EVENT_ACTIONS.each do |name, sql|
          return name if value.downcase == sql.downcase
        end
        raise BaseException.new("Action `#{value}` is not supported by SQLite3 adapter")
      end
    end
  end
end

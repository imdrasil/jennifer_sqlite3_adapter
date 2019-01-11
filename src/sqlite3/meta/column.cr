module Jennifer
  module SQLite3
    # :nodoc:
    class Column
      property id : Bool, name : String, nilable : Bool, default : String?
      getter type : String

      def initialize(rs)
        index = rs.read(Int32)
        @name = rs.read(String)
        @type = rs.read(String)
        @nilable = !rs.read(Bool)
        @default = rs.read(String?)
        @id = rs.read(Bool)
      end
    end
  end
end

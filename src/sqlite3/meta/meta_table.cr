require "./pragma"
require "./index"
require "./column"
require "./foreign_key"

module Jennifer
  module SQLite3
    # :nodoc:
    class MetaTable < View::Base
      include Pragma

      view_name "sqlite_master"

      mapping(
        type: {type: String},
        name: {type: String, primary: true},
        tbl_name: String,
        rootpage: Int32,
        sql: String
      )

      @columns : Array(Column)?
      @indexes : Array(Index)?
      @foreign_keys : Array(ForeignKey)?

      scope :tables { where { _type == "table" } }
      scope :table { |name| tables.where { _name == name } }
      scope :view { |name| where { (_type == "view") & (_name == name) } }
      scope :index { |name| index.where { (_name == name) } }
      scope :index { where { (_type == "index") } }

      def index?
        type == "index"
      end

      def table?
        type == "table"
      end

      def columns
        @columns ||= table? ? pragma_collection("table_info", name, Column) : [] of Column
      end

      def indexes
        @indexes ||=
          if table?
            pragma_collection("index_list", name, Index).tap { |array| array.each(&.meta) }
          else
            [] of Index
          end
      end

      def foreign_keys
        @foreign_keys ||=
          if table?
            pragma_collection("foreign_key_list", name, ForeignKey)
          else
            [] of ForeignKey
          end
      end

      def with_meta
        indexes
        columns
        foreign_keys
        self
      end

      private def adapter
        self.class.adapter
      end
    end
  end
end

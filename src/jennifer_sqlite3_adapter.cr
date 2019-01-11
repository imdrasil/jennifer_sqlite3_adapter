require "sqlite3"
require "jennifer/adapter"
require "./sqlite3/command_interface"
require "./sqlite3/sql_generator"
require "./sqlite3/schema_processor"
require "./sqlite3/meta/meta_table"

module Jennifer
  module SQLite3
    # Library version.
    VERSION = "0.1.0"

    class Adapter < Adapter::Base
      alias EnumType = String

      TYPE_TRANSLATIONS = {
        "bool"      => "integer",

        "integer"   => "integer",
        "bigint"    => "integer",
        "short"     => "integer",
        "tinyint"   => "integer",

        "float"     => "real",
        "double"    => "real",
        "real"      => "real",

        "text"      => "text",
        "string"    => "text",
        "varchar"   => "text",

        "time"      => "text",
        "timestamp" => "text",
      }

      def sql_generator
        SQLGenerator
      end

      def schema_processor
        @schema_processor ||= SchemaProcessor.new(self)
      end

      def translate_type(name : Symbol)
        translate_type(name.to_s)
      end

      def translate_type(name : String)
        TYPE_TRANSLATIONS[name]
      rescue e : KeyError
        raise BaseException.new("Unknown data alias #{name}")
      end

      def default_type_size(name); end

      def table_column_count(table)
        if table_exists?(table)
          MetaTable.table(table).first!.columns.size
        else
          -1
        end
      end

      def table_exists?(table)
        MetaTable.table(table).exists?
      end

      def view_exists?(table)
        MetaTable.view(table).exists?
      end

      def index_exists?(table, name)
        MetaTable.table(table).first.try(&.indexes.any?(&.name.==(name.to_s))) || false
      end

      def column_exists?(table, name)
        MetaTable.table(table).first.try(&.columns.any?(&.name.==(name.to_s))) || false
      end

      def foreign_key_exists?(from_table, to_table)
        MetaTable.table(from_table).first.try(&.foreign_keys.any?(&.to_table.==(to_table.to_s))) || false
      end

      def foreign_key_exists?(name)
        raise ArgumentError.new("Use table names instead")
      end

      def with_table_lock(table : String, type : String = "default", &block)
        transaction do |t|
          Config.logger.debug("SQLite3 doesn't support manual locking table from prepared statement." \
                              " Instead of this only transaction was started.")
          yield t
        end
      end

      def self.command_interface
        @@command_interface ||= CommandInterface.new(Config.instance)
      end
    end
  end
end

require "./sqlite3/result_set"

::Jennifer::Adapter.register_adapter("sqlite3", ::Jennifer::SQLite3::Adapter)

require "sqlite3"
require "jennifer/adapter"
require "./sqlite3/command_interface"
require "./sqlite3/sql_generator"
require "./sqlite3/schema_processor"
require "./sqlite3/meta/meta_table"

module Jennifer
  module SQLite3
    # Library version.
    VERSION = "0.4.0"

    class Adapter < Adapter::Base
      include ::Jennifer::Adapter::RequestMethods

      alias EnumType = String

      TYPE_TRANSLATIONS = {
        "integer" => "integer",
        "bigint"  => "integer",
        "short"   => "integer",
        "tinyint" => "integer",

        "float"  => "float",
        "decimal"  => "decimal",

        "text"    => "text",
        "string"  => "varchar",
        "varchar" => "varchar",

        "blob" => "blob",
        "boolean" => "boolean",
        "bool" => "boolean",
        "json" => "json",

        "date" => "date",
        "date_time" => "datetime",
        "datetime" => "datetime",
        "timestamp" => "datetime",
      }

      def self.default_max_bind_vars_count
        990
      end

      def self.protocol : String
        "sqlite3"
      end

      def prepare
        super

        with_connection do |conn|
          conn.exec "PRAGMA foreign_keys = ON"
        end
      end

      def sql_generator
        SQLGenerator
      end

      def schema_processor
        @schema_processor ||= SchemaProcessor.new(self)
      end

      def translate_type(name)
        TYPE_TRANSLATIONS[name.to_s.downcase]
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

      def tables_column_count(tables)
        MetaTable
          .all
          .tables
          .where { _tbl_name.in(tables) }
          .to_a
          .map do |table|
            Record.new({"table_name" => table.tbl_name, "count" => table.columns.size.to_i64} of String => DBAny)
          end
      end

      def table_exists?(table) : Bool
        MetaTable.table(table).exists?
      end

      def view_exists?(table) : Bool
        MetaTable.view(table).exists?
      end

      def index_exists?(table, name : String) : Bool
        MetaTable.table(table).first.try(&.indexes.any?(&.name.==(name.to_s))) || false
      end

      def column_exists?(table, name) : Bool
        MetaTable.table(table).first.try(&.columns.any?(&.name.==(name.to_s))) || false
      end

      def foreign_key_exists?(from_table, to_table = nil, column = nil, name : String? = nil) : Bool
        raise ArgumentError.new("SQLite3 adapter doesn't support #foreign_key_exists? with key name") if name

        table = MetaTable.table(from_table).first
        return false unless table && (to_table || column)

        to_table = to_table.to_s if to_table
        column = column.to_s if column
        table.foreign_keys.any? do |fk|
          result = true
          result &= fk.to_table == to_table if to_table
          result &= fk.column == column if column
          result
        end
      end

      def with_table_lock(table : String, type : String = "default", &block)
        transaction do |t|
          config.logger.debug do
            "SQLite3 doesn't support manual locking table from prepared statement." \
            " Instead of this only transaction was started."
          end
          yield t
        end
      end

      def explain(q) : String
        body = sql_generator.explain(q)
        args = q.sql_args
        plan = [%w(selectid order from detail)]
        query(*parse_query(body, args)) do |rs|
          rs.each do
            temp = %w()
            temp << rs.read.to_s
            temp << rs.read.to_s
            temp << rs.read.to_s
            temp << rs.read.to_s
            plan << temp
          end
        end

        plan.map(&.join("|")).join("\n")
      end

      def command_interface
        @command_interface ||= CommandInterface.new(config)
      end
    end
  end
end

require "./sqlite3/result_set"

::Jennifer::Adapter.register_adapter("sqlite3", ::Jennifer::SQLite3::Adapter)

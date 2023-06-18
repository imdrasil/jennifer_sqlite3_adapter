require "jennifer/adapter/base_sql_generator"

module Jennifer
  module SQLite3
    class SQLGenerator < Adapter::BaseSQLGenerator
      def self.insert(obj : Model::Base)
        opts = obj.arguments_to_insert
        String.build do |s|
          s << "INSERT INTO " << quote_identifier(obj.class.table_name)
          if !opts[:fields].empty?
            s << "("
            quote_identifiers(opts[:fields]).join(s, ", ")
            s << ") VALUES (" << escape_string(opts[:fields].size) << ") "
          else
            s << " DEFAULT VALUES"
          end
        end
      end

      def self.insert_on_duplicate(table, fields, rows : Int32, unique_fields, on_conflict)
        String.build do |io|
          io << "INSERT INTO " << quote_identifier(table) << " ("
          quote_identifiers(fields).join(io, ", ")
          escaped_row = "(" + escape_string(fields.size) + ")"
          io << ") VALUES "
          rows.times.join(io, ", ") { io << escaped_row }
          io << " ON CONFLICT ("
          quote_identifiers(unique_fields).join(io, ", ")
          io << ") "
          if on_conflict.empty?
            io << "DO NOTHING"
          else
            io << "DO UPDATE SET "
            on_conflict.each_with_index do |(field, value), index|
              io << ", " if index != 0
              io << field_assign_statement(field.to_s, value)
            end
          end
        end
      end

      # Generates update request depending on given query and hash options.
      def self.update(query, options : Hash)
        esc = escape_string(1)
        String.build do |s|
          s << "UPDATE " << quote_identifier(query.table)
          s << " SET "
          options.join(s, ", ") { |(k, _)| s << quote_identifier(k) << " = " << esc }
          s << " "
          where_clause(s, query.tree)
        end
      end

      def self.order_expression(expression : QueryBuilder::OrderExpression)
        if expression.null_position.none?
          super
        else
          String.build do |io|
            io << "CASE WHEN " <<
              expression.criteria.is(nil).as_sql(self) <<
              " THEN 0 ELSE 1 " <<
              (expression.null_position.last? ? "DESC" : "ASC") <<
              " END, " <<
              super
          end
        end
      end

      # SQLite doesn't support truncate command.
      def self.truncate(table : String)
        raise BaseException.new("TRUNCATE command isn't supported")
      end

      # SQLite doesn't support LOCK statement.
      def self.lock_clause(io, query)
        return if query._lock.nil?
        raise BaseException.new("LOCK command isn't supported")
      end

      # SQLite doesn't support JSON at all.
      def self.json_path(path : QueryBuilder::JSONSelector)
        # raise BaseException.new("JSON selector isn't supported")

        operator =
          case path.type
          when :path
            "->"
          when :take
            "->>"
          else
            raise "Wrong json path type"
          end
        "#{path.identifier(self)}#{operator}#{quote(path.path)}"
      end

      def self.values_expression(field : Symbol)
        "excluded.#{field}"
      end

      def self.explain(query)
        "EXPLAIN QUERY PLAN #{self.select(query)}"
      end

      def self.quote(value : String)
        "'#{value.gsub('\'', "''")}'"
      end

      def self.quote(value : Bool)
        value ? 1 : 0
      end

      def self.quote(value : Time)
        "'#{value.to_utc.to_s("%F %T.0")}'"
      end

      def self.quote_identifier(identifier : String | Symbol)
        %("#{identifier.to_s.gsub('"', %(""))}")
      end

      def self.quote_table(table : String)
        %("#{table.gsub(".", %("."))}")
      end
    end
  end
end

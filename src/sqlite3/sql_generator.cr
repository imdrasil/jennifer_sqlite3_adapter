require "jennifer/adapter/base_sql_generator"

module Jennifer
  module SQLite3
    class SQLGenerator < Adapter::BaseSQLGenerator
      def self.insert(obj : Model::Base)
        opts = obj.arguments_to_insert
        String.build do |s|
          s << "INSERT INTO " << obj.class.table_name
          if !opts[:fields].empty?
            s << "("
            opts[:fields].join(s, ", ")
            s << ") VALUES (" << escape_string(opts[:fields].size) << ") "
          else
            s << " DEFAULT VALUES"
          end
        end
      end

      def self.insert_on_duplicate(table, fields, rows : Int32, unique_fields, on_conflict)
        raise BaseException.new("SQLite3 doesn't support UPSERT. Consider using plain REPLACE")
      end

      # Generates update request depending on given query and hash options.
      def self.update(query, options : Hash)
        esc = escape_string(1)
        String.build do |s|
          s << "UPDATE " << query.table
          s << " SET "
          options.join(s, ", ") { |(k, _)| s << k << " = " << esc }
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
        raise BaseException.new("JSON selector isn't supported")
      end

      def self.values_expression(field)
        "VALUES(#{field})"
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
    end
  end
end

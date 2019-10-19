require "jennifer/adapter/schema_processor"

module Jennifer
  module SQLite3
    class SchemaProcessor < Adapter::SchemaProcessor
      def rename_table(old_name, new_name)
        adapter.exec "ALTER TABLE #{old_name.to_s} RENAME TO #{new_name.to_s}"
      end

      def drop_column(table, name)
        ignore_foreign_keys do
          temp_table_name = "#{table}_temp"
          t = find_table(table)
          columns = t.columns.reject(&.name.==(name.to_s))

          # Create new table
          create_table(temp_table_name, columns, t.foreign_keys)

          # Copy data
          copy_data(temp_table_name, table, columns.map(&.name))

          # Drop old table
          drop_table(table)

          # Rename new table
          rename_table(temp_table_name, table)

          # Add indexes
          create_indexes(t)
        end
      end

      def change_column(table, old_name, new_name, opts : Hash)
        ignore_foreign_keys do
          temp_table_name = "#{table}_temp"
          t = find_table(table)
          fields = t.columns.map(&.name)
          new_fields = fields.clone

          new_fields[fields.index(&.==(old_name.to_s)).as(Int32)] = new_name.to_s


          # Create new table
          create_table(temp_table_name, t.columns.reject(&.name.==(old_name.to_s)), t.foreign_keys)

          # Create new column
          add_column(temp_table_name, new_name, opts)

          # Copy data
          copy_data(temp_table_name, table, new_fields, fields)

          # Drop old table
          drop_table(table)

          # Rename new table
          rename_table(temp_table_name, table)

          # Add indexes
          create_indexes(t)
        end
      end

      def add_foreign_key(from_table, to_table, column, primary_key, _name = nil, *, on_update = nil, on_delete = nil)
        table = from_table
        ignore_foreign_keys do
          temp_table_name = "#{table}_temp"
          t = find_table(table)

          # Create new table with FK
          fk = ForeignKey.new(to_table.to_s, column.to_s, primary_key.to_s, on_update: on_update, on_delete: on_delete)
          create_table(temp_table_name, t.columns, t.foreign_keys + [fk])

          # Copy data
          copy_data(temp_table_name, table, t.columns.map(&.name))

          # Drop old table
          drop_table(table)

          # Rename new table
          rename_table(temp_table_name, table)

          # Add indexes
          create_indexes(t)
        end
      end

      def drop_foreign_key(from_table, name : String)
        to_table = to_table_from_fk_name(from_table.to_s, name)
        table = from_table
        ignore_foreign_keys do
          temp_table_name = "#{table}_temp"
          t = find_table(table)

          # Create new table without FK
          create_table(temp_table_name, t.columns, t.foreign_keys.reject(&.to_table.==(to_table)))

          # Copy data
          copy_data(temp_table_name, table, t.columns.map(&.name))

          # Drop old table
          drop_table(table)

          # Rename new table
          rename_table(temp_table_name, table)

          # Add indexes
          create_indexes(t)
        end
      end

      private def copy_data(target, source, target_fields, source_fields = target_fields)
        adapter.exec <<-SQL
        INSERT INTO #{target} (#{target_fields.join(", ")})
        SELECT #{source_fields.join(", ")}
        FROM #{source}
        SQL
      end

      private def create_table(name : String, columns : Array(Column), foreign_keys : Array(ForeignKey))
        create_table_sql =
          String.build do |io|
            io << "CREATE TABLE " << name << "("
            columns.each_with_index do |column, i|
              io << ", " if i != 0
              opts = { :primary => column.id, :type => column.type } of Symbol => Bool | String
              opts[:null] = false if column.nilable == false
              opts[:default] = column.default.not_nil! if column.default
              column_definition(column.name, opts, io, true)
            end

            foreign_keys.each do |key|
              io << ","
              io << "FOREIGN KEY (" << key.column << ") REFERENCES " << key.to_table << "(" << key.primary_key << ")"
              on_update = key.on_update || "RESTRICT"
              io << " ON UPDATE " << on_update
              on_delete = key.on_delete || "RESTRICT"
              io << " ON DELETE " << on_delete
            end
            io << ')'
          end
        adapter.exec(create_table_sql)
      end

      private def create_indexes(t, table = t.name)
        t.indexes.each do |index|
          next if index.primary?
          create_index(table, index)
        end
      end

      private def create_index(table, index : Index)
        if index.columns.any?(&.desc?)
          orders = {} of String => Symbol
          index.columns.each { |column| orders[column.column!] = column.desc? ? :desc : :asc }
          add_index(table, index.name, index.columns.map(&.column), index.type, orders)
        else
          add_index(table, index.name, index.columns.map(&.column), index.type)
        end
      end

      private def column_definition(name, options, io, as_is : Bool = false)
        type = options[:sql_type]? || adapter.translate_type(options[:type].as(Symbol | String))
        io << name << " " << type
        if options.has_key?(:null)
          io << " NOT" unless options[:null]
          io << " NULL"
        end
        io << " PRIMARY KEY" if options[:primary]?
        if options.has_key?(:default)
          io << " DEFAULT "
          io << (as_is ? options[:default] : self.adapter.class.t(options[:default]))
        end
        io << " AUTOINCREMENT" if options[:auto_increment]?
      end

      private def index_type_translate(name : Symbol?)
        case name
        when :unique, :uniq
          "UNIQUE "
        when nil
          " "
        else
          raise ArgumentError.new("Unknown index type: #{name}")
        end
      end

      private def drop_table(table : String)
        drop_table(Migration::TableBuilder::DropTable.new(adapter, table))
      end

      # Format of system generated FK name is `fk_cr_tableA_tableB`.
      private def table_names_from_fk(name)
        name[6..-1]
      end

      private def to_table_from_fk_name(from_table, name)
        part = table_names_from_fk(name)

        if part.starts_with?(from_table)
          part[(from_table.size + 1)..-1]
        elsif part.ends_with?(from_table)
          part[0...-(from_table.size + 1)]
        else
          raise ArgumentError.new("Bad foreign key name - #{name}")
        end
      end

      private def find_table(name)
        MetaTable.table(name).first!.with_meta
      end

      private def ignore_foreign_keys
        adapter.exec "PRAGMA foreign_keys=OFF"
        yield
        adapter.exec "PRAGMA foreign_keys=ON"
      end
    end
  end
end

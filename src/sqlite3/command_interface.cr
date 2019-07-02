require "jennifer/adapter/db_command_interface"

module Jennifer
  module SQLite3
    class CommandInterface < Adapter::DBCommandInterface
      def create_database
        options = [db_path, ""] of Command::Option
        command = Command.new(
          executable: "sqlite3",
          options: options
        )
        execute(command)
      end

      def drop_database
        options = [db_path] of Command::Option
        command = Command.new(
          executable: "rm",
          options: options
        )
        execute(command)
      end

      def generate_schema
        options = [db_path, ".schema"] of Command::Option
        command = Command.new(
          executable: "sqlite3",
          options: options,
          out_stream: " | grep -v sqlite_sequence > #{config.structure_path}"
        )
        execute(command)
      end

      def load_schema
        options = [db_path] of Command::Option
        command = Command.new(
          executable: "sqlite3",
          options: options,
          in_stream: "cat #{config.structure_path} |"
        )
        execute(command)
      end

      def database_exists?
        command = Command.new(
          executable: "test",
          options: ["-e", db_path] of Command::Option
        )
        execute(command)
        true
      rescue error : Command::Failed
        false
      end

      private def db_path
        File.join(config.host, config.db)
      end
    end
  end
end

require "spec"
require "./jennifer_setup"
require "./support/feature_helper"
require "./models"
# require "factory"
require "./support/migrations/*"

class Jennifer::Adapter::Base
  def clear_connection
    db.close
    @db = nil
  end
end

class Jennifer::SQLite3::CommandInterface
  getter last_command : Command?

  def execute(command)
    @last_command = command
    super
  end
end

def schema_rollback
  Spec.adapter.rollback_transaction
  yield
ensure
  Spec.adapter.clear_connection
  Jennifer::Migration::Runner.drop if Spec.adapter.database_exists?
  Jennifer::Migration::Runner.create
  Jennifer::Migration::Runner.migrate
  Spec.adapter.begin_transaction
end

def read_to_end(rs)
  rs.each do
    rs.column_names.size.times do
      rs.read
    end
  end
end

Spec.before_each do
  setup_jennifer
  Spec.logger_backend.entries.clear
  Spec.adapter.begin_transaction
end

Spec.after_each do
  Spec.adapter.rollback_transaction
end

require "spec"
require "./jennifer_setup"
require "./support/feature_helper"
require "./models"
# require "factory"
require "./support/migrations/*"

def schema_rollback
  Jennifer::Adapter.default_adapter.rollback_transaction
  yield
ensure
  [Post, User].each do |model_class|
    Jennifer::Adapter.default_adapter.exec("DROP TABLE IF EXISTS #{model_class.table_name}")
  end
  Jennifer::Migration::Version.all.delete
  Jennifer::Migration::Runner.migrate
  Jennifer::Adapter.default_adapter.begin_transaction
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

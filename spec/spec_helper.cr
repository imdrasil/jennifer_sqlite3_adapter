require "spec"
require "json"
require "./jennifer_setup"
require "./models"
# require "factory"
require "./support/array_logger"
require "./support/migrations/*"

module Spec
  class_getter logger = ArrayLogger.new(STDOUT)

  def self.adapter
    Jennifer::Adapter.adapter
  end
end

def schema_rollback
  Jennifer::Adapter.adapter.rollback_transaction
  yield
ensure
  [Post, User].each do |model_class|
    Jennifer::Adapter.adapter.exec("DROP TABLE IF EXISTS #{model_class.table_name}")
  end
  Jennifer::Migration::Version.all.delete
  Jennifer::Migration::Runner.migrate
  Jennifer::Adapter.adapter.begin_transaction
end

def setup_jennifer
  Jennifer::Config.configure do |conf|
    conf.logger = Spec.logger
    conf.logger.level = Logger::DEBUG
    conf.user = "anyuser"
    conf.password = "anypassword"
    conf.host = "."
    conf.adapter = "sqlite3"
    conf.db = "test.db"
    conf.verbose_migrations = false
  end
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
  Spec.adapter.begin_transaction
end

Spec.after_each do
  Spec.logger.clear
  Spec.adapter.rollback_transaction
end

setup_jennifer

require "jennifer"
require "../src/jennifer_sqlite3_adapter"

module Spec
  class_getter logger_backend = Log::MemoryBackend.new
  class_getter logger = Log.for("db", Log::Severity::Debug)

  def self.adapter
    Jennifer::Adapter.default_adapter
  end
end

def setup_jennifer
  Jennifer::Config.configure do |conf|
    conf.read("./spec/support/database.yml", "test")
    conf.logger = Spec.logger
    conf.verbose_migrations = false
  end

  Log.setup "db", :debug, Spec.logger_backend
end

setup_jennifer

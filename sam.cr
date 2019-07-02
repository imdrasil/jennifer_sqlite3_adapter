require "jennifer"
require "json"
require "./src/jennifer_sqlite3_adapter"
require "./spec/support/migrations/*"
require "sam"
require "jennifer/sam"

Jennifer::Config.configure do |conf|
  conf.logger.level = Logger::ERROR
  conf.user = "anyuser"
  conf.password = "anypassword"
  conf.host = "./"
  conf.adapter = "sqlite3"
  conf.db = "test.db"
  conf.migration_files_path = "./spec/support/migrations"
end

Sam.help

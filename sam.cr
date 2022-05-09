require "sam"
require "jennifer"
require "jennifer/sam"

require "./src/jennifer_sqlite3_adapter"
require "./spec/support/feature_helper"
require "./spec/support/migrations/*"

Jennifer::Config.configure do |conf|
  conf.read("./spec/support/database.yml", "test")
  conf.logger = Log.for("db", :error)
end

Sam.help

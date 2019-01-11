require "../spec_helper"

abstract class Jennifer::Adapter::DBCommandInterface
  getter last_command : Command?
  def execute(command)
    @last_command = command
  end
end

describe Jennifer::SQLite3::CommandInterface do
  described_class = Jennifer::SQLite3::CommandInterface

  describe "#create_database" do
    it do
      interface = described_class.new(Jennifer::Config.config)
      interface.create_database

      interface.last_command.not_nil!.tap do |command|
        command.executable.should eq("sqlite3")
        command.options.should eq(["./test.db", ""])
        command.in_stream.should be_empty
        command.out_stream.should be_empty
      end
    end
  end

  describe "#drop_database" do
    it do
      interface = described_class.new(Jennifer::Config.config)
      interface.drop_database

      interface.last_command.not_nil!.tap do |command|
        command.executable.should eq("rm")
        command.options.should eq(["./test.db"])
        command.in_stream.should be_empty
        command.out_stream.should be_empty
      end
    end
  end

  describe "#generate_schema" do
    it do
      interface = described_class.new(Jennifer::Config.config)
      interface.generate_schema

      interface.last_command.not_nil!.tap do |command|
        command.executable.should eq("sqlite3")
        command.options.should eq(["./test.db", ".schema"])
        command.in_stream.should be_empty
        command.out_stream.should eq(" | grep -v sqlite_sequence > ./db/structure.sql")
      end
    end
  end

  describe "#load_schema" do
    it do
      interface = described_class.new(Jennifer::Config.config)
      interface.load_schema

      interface.last_command.not_nil!.tap do |command|
        command.executable.should eq("sqlite3")
        command.options.should eq(["./test.db"])
        command.in_stream.should eq("cat ./db/structure.sql |")
        command.out_stream.should be_empty
      end
    end
  end
end

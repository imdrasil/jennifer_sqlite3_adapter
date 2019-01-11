require "../../spec_helper"

describe Jennifer::SQLite3::ForeignKey do
  fk = Jennifer::SQLite3::MetaTable.table("posts").first!.foreign_keys[0]

  describe ".new" do
    pending "add"
  end

  describe "#column" do
    it { fk.column.should eq("user_id") }
  end

  describe "#primary_key" do
    it { fk.primary_key.should eq("id") }
  end

  describe "#to_table" do
    it { fk.to_table.should eq("users") }
  end
end

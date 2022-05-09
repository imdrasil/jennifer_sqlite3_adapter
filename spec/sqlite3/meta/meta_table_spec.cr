require "../../spec_helper"

describe Jennifer::SQLite3::MetaTable do
  described_class = Jennifer::SQLite3::MetaTable

  table = described_class.table("users").first!
  index = described_class.index("name_index").first!

  describe "#index?" do
    it { table.index?.should be_false }
    it { index.index?.should be_true }
  end

  describe "#table?" do
    it { described_class.table("users").first!.index?.should be_false }
    it { described_class.index("name_index").first!.index?.should be_true }
  end

  describe "#columns" do
    expected_number = 6
    FeatureHelper.with_json_support { expected_number = 7 }

    it { index.columns.should be_empty }
    it { table.columns.size.should eq(expected_number) }
  end

  describe "#indexes" do
    it { index.indexes.should be_empty }
    it { table.indexes.size.should eq(1) }
  end

  describe "#foreign_keys" do
    it { index.foreign_keys.should be_empty }
    it { described_class.table("posts").first!.foreign_keys.size.should eq(1) }
  end

  describe ".table" do
    pending "add"
  end

  describe ".index" do
    pending "add"
  end
end

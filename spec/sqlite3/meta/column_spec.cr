require "../../spec_helper"

describe Jennifer::SQLite3::Column do
  described_class = Jennifer::SQLite3::Column

  user_columns = [] of Jennifer::SQLite3::Column

  Spec.adapter.query("pragma table_info(users)") do |rs|
    rs.each { user_columns << described_class.new(rs) }
  end

  describe ".new" do
    it "reads all columns from pragma" do
      user_columns.size.should eq(6)
    end
  end

  describe "#id" do
    it { user_columns[0].id.should be_true }
    it { user_columns[1].id.should be_false }
  end

  describe "#default" do
    it { user_columns[1].default.should be_nil }
    it { user_columns.find(&.name.==("admin")).not_nil!.default.should eq("false") }
  end

  describe "#nilable" do
    it { user_columns[1].nilable.should be_false }
    it { user_columns[2].nilable.should be_true }
  end

  describe "#type" do
    it { user_columns[1].type.should eq("varchar") }
    it { user_columns[2].type.should eq("INTEGER") }
  end

  describe "#name" do
    it { user_columns[1].name.should eq("name") }
  end
end

require "../../spec_helper"

describe Jennifer::SQLite3::Index do
  user_indexes = Jennifer::SQLite3::MetaTable.table("users").first!.indexes

  describe Jennifer::SQLite3::Index::Meta do
    meta = user_indexes[0].meta

    describe "#column" do
      it { meta[0].column.should eq("name") }
      it { meta[1].column.should be_nil }
    end

    describe "#desc?" do
      it { meta[0].desc?.should be_false }
      pending "add desc index"
    end

    describe "#asc?" do
      it { meta[0].asc?.should be_true }
      pending "add desc index"
    end
  end

  describe ".new" do
    pending "add"
  end

  describe "#name" do
    it { user_indexes[0].name.should eq("name_index") }
  end

  describe "#type" do
    pending { user_indexes[0].type.should be_nil }
    it { user_indexes[0].type.should eq(:unique) }
  end

  describe "#source" do
    it { user_indexes[0].source.should eq("c") }
  end

  describe "#partial" do
    it { user_indexes[0].partial.should be_false }
  end

  describe "#meta" do
    it { user_indexes[0].meta.should_not be_empty }
  end

  describe "#columns" do
    it { user_indexes[0].columns.should eq([user_indexes[0].meta[0]]) }
  end

  describe "#primary?" do
    it { user_indexes[0].primary?.should be_false }
  end

  describe "#secondary?" do
    it { user_indexes[0].secondary?.should be_true }
  end
end

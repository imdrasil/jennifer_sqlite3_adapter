require "./spec_helper"

# TODO: test modal bool field

describe Jennifer::SQLite3::Adapter do
  adapter = Spec.adapter

  describe "data types" do
    describe Bool do
      it { User.create!({name: "User"}).reload.admin?.should be_false }
      it { User.create!({name: "User", admin: true}).reload.admin?.should be_true }
    end

    describe Float64 do
      it { Post.create!({title: "T", text: "T"}).reload.rating.should eq(0.0) }
    end

    describe Time do
      it do
        time = Time.now
        user = User.create!({name: "User"})
        user.reload.created_at!.should be_close(time, 0.001.seconds)
      end
    end
  end

  describe "#sql_generator" do
    it { adapter.sql_generator.should eq(Jennifer::SQLite3::SQLGenerator) }
  end

  describe "#schema_processor" do
    it { adapter.schema_processor.is_a?(Jennifer::SQLite3::SchemaProcessor).should be_true }
  end

  describe "#translate_type" do
    context "with missing type" do
      it do
        expect_raises(Jennifer::BaseException) do
          adapter.translate_type(:decimal)
        end
      end
    end

    describe "integer" do
      it do
        %i(bool integer bigint short tinyint).each { |type| adapter.translate_type(type).should eq("integer") }
      end
    end

    describe "real" do
      it do
        %i(float double real).each { |type| adapter.translate_type(type).should eq("real") }
      end
    end

    describe "text" do
      it do
        %i(text string varchar time timestamp).each { |type| adapter.translate_type(type).should eq("text") }
      end
    end
  end

  describe "#default_type_size" do
    it { adapter.default_type_size(:string).should be_nil }
  end

  describe "#table_column_count" do
    context "with name of existing table" do
      it { adapter.table_column_count("users").should eq(6) }
    end

    context "with name of missing table" do
      it { adapter.table_column_count("sqlite_masterrrrr").should eq(-1) }
    end
  end

  describe "#table_exists?" do
    context "with name of existing table" do
      it { adapter.table_exists?("users").should be_true }
    end

    context "with name of missing table" do
      it { adapter.table_exists?("sqlite_masterrrrr").should be_false }
    end
  end

  describe "#view_exists?" do
    context "with name of existing view" do
      pending "add" { adapter.view_exists?("users").should be_true }
    end

    context "with name of missing view" do
      it { adapter.view_exists?("sqlite_masterrrrr").should be_false }
    end
  end

  describe "#index_exists?" do
    context "with name of existing index" do
      it { adapter.index_exists?("users", "name_index").should be_true }
    end

    context "with name of missing index" do
      it { adapter.index_exists?("sqlite_masterrrrr", "name_index").should be_false }
      it { adapter.index_exists?("users", "missing_index").should be_false }
    end
  end

  describe "#column_exists?" do
    context "with name of existing column" do
      it { adapter.column_exists?("users", "name").should be_true }
    end

    context "with name of missing column" do
      it { adapter.column_exists?("sqlite_masterrrrr", "name").should be_false }
      it { adapter.column_exists?("users", "missing_column").should be_false }
    end
  end

  describe "#foreign_key_exists?" do
    context "with existing foreign key" do
      it { adapter.foreign_key_exists?("posts", "users").should be_true }
    end

    context "with missing foreign key" do
      it { adapter.foreign_key_exists?("users", "posts").should be_false }
      it { adapter.foreign_key_exists?("posts", "missing_table").should be_false }
    end

    context "with foreign key name" do
      it do
        expect_raises(ArgumentError) do
          adapter.foreign_key_exists?("some_name")
        end
      end
    end
  end

  describe "#with_table_lock" do
    it "adds log message" do
      adapter.with_table_lock("any_table") {}
      Spec.logger.container[-2].should eq({
        sev: "DEBUG",
        msg: "SQLite3 doesn't support manual locking table from prepared statement. Instead of this only transaction was started."
      })
    end
  end

  describe "#command_interface" do
    it { adapter.class.command_interface.is_a?(Jennifer::SQLite3::CommandInterface).should be_true }
  end
end

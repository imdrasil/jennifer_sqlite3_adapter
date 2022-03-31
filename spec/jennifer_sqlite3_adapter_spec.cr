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
        time = Time.local
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
          adapter.translate_type(:xml)
        end
      end
    end

    describe "integer" do
      it do
        %i(integer bigint short tinyint).each { |type| adapter.translate_type(type).should eq("integer") }
      end
    end

    describe "boolean" do
      it do
        %i(bool).each { |type| adapter.translate_type(type).should eq("boolean") }
      end
    end

    describe "float" do
      it do
        %i(float).each { |type| adapter.translate_type(type).should eq("float") }
      end
    end

    describe "decimal" do
      it do
        %i(decimal).each { |type| adapter.translate_type(type).should eq("decimal") }
      end
    end

    describe "text" do
      it do
        %i(text).each { |type| adapter.translate_type(type).should eq("text") }
      end
    end

    describe "varchar" do
      it do
        %i(string varchar).each { |type| adapter.translate_type(type).should eq("varchar") }
      end
    end

    describe "json" do
      it do
        %i(json).each { |type| adapter.translate_type(type).should eq("json") }
      end
    end

    describe "date" do
      it do
        %i(date).each { |type| adapter.translate_type(type).should eq("date") }
      end
    end

    describe "date_time" do
      it do
        %i(date_time timestamp).each { |type| adapter.translate_type(type).should eq("datetime") }
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

  describe "#tables_column_count" do
    it "returns amount of tables fields" do
      adapter.tables_column_count(["users", "posts"]).to_a.map(&.count).should eq([6, 7])
    end

    pending "returns amount of views fields" do
      adapter.tables_column_count(["male_contacts", "female_contacts"]).to_a.map(&.count).should eq([9, 10])
    end

    it "returns nothing for unknown tables" do
      adapter.tables_column_count(["missing_table"]).to_a.should be_empty
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

    context "with column name" do
      it { adapter.foreign_key_exists?("posts", "users", "user_id").should be_true }
      it { adapter.foreign_key_exists?("posts", "users", "post_id").should be_false }
    end

    context "with foreign key name" do
      it do
        expect_raises(ArgumentError) do
          adapter.foreign_key_exists?("users", name: "some_name")
        end
      end
    end
  end

  describe "#with_table_lock" do
    it "adds log message" do
      adapter.with_table_lock("any_table") { }
      Spec.logger_backend.entries[-2].severity.debug?.should be_true
      Spec.logger_backend.entries[-2].message.should eq("SQLite3 doesn't support manual locking table from prepared statement. Instead of this only transaction was started.")
    end
  end

  describe "#command_interface" do
    it { adapter.command_interface.is_a?(Jennifer::SQLite3::CommandInterface).should be_true }
  end

  describe "#explain" do
    it do
      result = adapter.explain(Jennifer::Query["users"].join("posts") { |origin, joined| joined._user_id == origin._id }).split("\n")
      result.size.should eq(3)
      result[0].should eq("selectid|order|from|detail")
      result[1].should match(/\d\|\d\|\d\|SCAN posts/)
    end
  end

  describe "#update" do
    context "given object" do
      it "updates fields if they were changed" do
        user = User.create({name: "Adam"})
        user.name = "new name"
        r = adapter.update(user)
        r.rows_affected.should eq(1)
      end
    end
  end

  describe "#exec" do
    it "execs query" do
      adapter.exec(
        "insert into users(name, admin, created_at, updated_at) values('new', 0, ?, ?)",
        [Time.local, Time.local]
      )
    end

    it "raises exception if query is broken" do
      expect_raises(Jennifer::BadQuery, /Original query was/) do
        adapter.exec("insert into countries(name) set values(?)", ["new"])
      end
    end
  end

  describe "#query" do
    it "perform query" do
      adapter.query("select * from users") { |rs| read_to_end(rs) }
    end

    it "raises exception if query is broken" do
      expect_raises(Jennifer::BadQuery, /Original query was/) do
        adapter.query("select * from table users") { |rs| read_to_end(rs) }
      end
    end
  end

  describe "#upsert" do
    it "correctly executes ON CONFLICT DO UPDATE" do
      user = User.create({name: "Ivan", age: 23})
      values = [
        ["Ivan", 44, Time.local, Time.local],
        ["Natan", 30, Time.local, Time.local],
      ]
      User.all.upsert(%w(name age created_at updated_at), values, %w(name)) { {:age => 1, :name => "a"} }
      user.reload
      added_user = User.all.last!

      user.name.should eq("a")
      user.age.should eq(1)
      added_user.name.should eq("Natan")
      added_user.age.should eq(30)
    end

    it "correctly executes ON CONFLICT IGNORE" do
      user = User.create({name: "Ivan", age: 23})
      values = [
        ["Ivan", 44, Time.local, Time.local],
        ["Natan", 30, Time.local, Time.local],
      ]
      User.all.upsert(%w(name age created_at updated_at), values, %w(name))
      user.reload
      added_user = User.all.last!

      user.name.should eq("Ivan")
      user.age.should eq(23)
      added_user.name.should eq("Natan")
      added_user.age.should eq(30)
      User.all.count.should eq(2)
    end

    it "correctly utilize reference to inserting row" do
      user = User.create({name: "Ivan", age: 23})
      values = [
        ["Ivan", 44, Time.local, Time.local],
      ]
      User.all.upsert(%w(name age created_at updated_at), values, %w(name)) do
        {:age => values(:age) + 1, :name => values(:name)}
      end
      user.reload

      user.name.should eq("Ivan")
      user.age.should eq(45)
    end
  end

  describe "#delete" do
    it "removes record from db" do
      User.create({name: "Ivan", age: 23})
      adapter.delete(User.all)
      User.all.count.should eq(0)
    end
  end

  describe "#truncate" do
    it "raise an exception" do
      User.create({name: "Ivan", age: 23})
      expect_raises(Jennifer::BaseException, "TRUNCATE command isn't supported") do
        adapter.truncate(User.table_name)
      end
    end
  end

  describe "#exists?" do
    it "returns true if record exists" do
      User.create({name: "Ivan", age: 23})
      adapter.exists?(User.all).should be_true
    end

    it "returns false if record doesn't exist" do
      adapter.exists?(User.all).should be_false
    end
  end

  describe "#count" do
    it "returns count of objects" do
      User.create({name: "Ivan", age: 23})
      adapter.count(User.all).should eq(1)
    end
  end
end

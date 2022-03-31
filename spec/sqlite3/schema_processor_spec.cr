require "../spec_helper"

describe Jennifer::SQLite3::SchemaProcessor do
  adapter = Spec.adapter
  processor = adapter.schema_processor
  master_class = Jennifer::SQLite3::MetaTable

  describe "#rename_table" do
    it do
      processor.rename_table("users", "profiles")
      adapter.table_exists?("profiles").should be_true
    end
  end

  describe "#drop_column" do
    it do
      schema_rollback do
        User.generate_list(2)
        processor.drop_column("users", "info")

        adapter.table_exists?("users").should be_true
        adapter.table_exists?("users_temp").should be_false
        adapter.column_exists?("users", "info").should be_false
        User.all.count.should eq(2)
        adapter.index_exists?("users", "name_index").should be_true
      end
    end
  end

  describe "#change_column" do
    describe "rename" do
      it do
        schema_rollback do
          User.generate_list(2)
          processor.change_column("users", "age", "new_age", {:type => :integer})

          adapter.table_exists?("users").should be_true
          adapter.table_exists?("users_temp").should be_false
          adapter.column_exists?("users", "age").should be_false
          adapter.column_exists?("users", "new_age").should be_true
          User.all.count.should eq(2)
          adapter.index_exists?("users", "name_index").should be_true
        end
      end
    end

    describe "add default" do
      it do
        schema_rollback do
          User.generate_list(2)
          processor.change_column("users", "age", "age", {:type => :integer, :default => 12})

          adapter.table_exists?("users").should be_true
          adapter.table_exists?("users_temp").should be_false
          adapter.column_exists?("users", "age").should be_true
          User.all.count.should eq(2)
          adapter.index_exists?("users", "name_index").should be_true
          master_class.table("users").first!.columns.find(&.name.==("age")).not_nil!.default.should eq("12")
        end
      end
    end

    describe "change type" do
      it do
        schema_rollback do
          User.generate_list(2)
          processor.change_column("users", "age", "age", {:type => :float})

          adapter.table_exists?("users").should be_true
          adapter.table_exists?("users_temp").should be_false
          adapter.column_exists?("users", "age").should be_true
          User.all.count.should eq(2)
          adapter.index_exists?("users", "name_index").should be_true
          master_class.table("users").first!.columns.find(&.name.==("age")).not_nil!.type.should eq("float")
        end
      end
    end
  end

  describe "#add_foreign_key" do
    it do
      schema_rollback do
        User.generate_list(2)
        Post.create(title: "User 0", text: "Text")
        Post.create(title: "User 1", text: "Text")
        processor.add_foreign_key("users", "posts", "name", "title", "index_name", :restrict, :restrict)

        adapter.table_exists?("users").should be_true
        adapter.table_exists?("users_temp").should be_false
        User.all.count.should eq(2)
        adapter.index_exists?("users", "name_index").should be_true
        master_class.table("users").first!.foreign_keys.size.should eq(1)
      end
    end
  end

  describe "#drop_foreign_key" do
    it do
      schema_rollback do
        Post.generate_list(2)
        processor.drop_foreign_key("posts", "users", "fk_cr_11111")

        adapter.table_exists?("posts").should be_true
        adapter.table_exists?("posts_temp").should be_false
        Post.all.count.should eq(2)
        adapter.index_exists?("users", "name_index").should be_true
        master_class.table("posts").first!.foreign_keys.should be_empty
      end
    end
  end
end

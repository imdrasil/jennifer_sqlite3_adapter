require "../spec_helper"

private def build_expression
  Jennifer::QueryBuilder::ExpressionBuilder.new("table")
end

private def build_criteria
  Jennifer::QueryBuilder::Criteria.new("f1", "tests")
end

private macro quote_example(value)
  it do
    executed = false
    value = {{value}}
    query = "SELECT #{described_class.quote(value)}"
    adapter.query(query) do |rs|
      rs.each do
        result =
          case value
          when Time
            rs.read(Time)
          when Bool
            rs.read(Bool)
          else
            rs.read
          end
        result.should eq(value)
        executed = true
      end
    end
    executed.should be_true
  end
end

describe Jennifer::SQLite3::SQLGenerator do
  described_class = Jennifer::SQLite3::SQLGenerator
  adapter = Jennifer::Adapter.default_adapter

  describe ".insert" do
    it do
      described_class.insert(User.build({name: "User"}))
        .should eq(%(INSERT INTO "users"("name", "age", "admin", "created_at", "updated_at") VALUES (%s, %s, %s, %s, %s) ))
    end
  end

  describe ".insert_on_duplicate" do
    pending "add"
  end

  describe ".update" do
    it do
      described_class.update(User.all, {"name" => "Peter"}).should eq(%(UPDATE "users" SET "name" = %s ))
    end
  end

  describe ".order_expression" do
    context "without specifying position of null" do
      context "with raw sql" do
        it do
          build_expression.sql("some sql").asc.as_sql.should eq("some sql ASC")
          build_expression.sql("some sql").desc.as_sql.should eq("some sql DESC")
        end
      end

      it do
        build_criteria.asc.as_sql.should eq(%("tests"."f1" ASC))
        build_criteria.desc.as_sql.should eq(%("tests"."f1" DESC))
      end
    end
  end

  describe ".truncate" do
    pending "add"
  end

  describe ".lock_clause" do
    it do
      query = User.all.lock("FOR NO KEY UPDATE")
      expect_raises(Jennifer::BaseException, "LOCK command isn't supported") do
        String.build { |io| described_class.lock_clause(io, query) }.should eq("")
      end
    end
  end

  describe ".json_path" do
    it do
      expect_raises(Jennifer::BaseException) do
        described_class.json_path(Jennifer::QueryBuilder::Criteria.new("table", "field").take(1))
      end
    end
  end

  describe ".quote" do
    quote_example(Time.utc(2010, 10, 10, 12, 34, 56))
    quote_example(Time.utc(2010, 10, 10, 0, 0, 0))
    quote_example(nil)
    quote_example(true)
    quote_example(false)
    quote_example(%(foo))
    quote_example(%(this has a \\))
    quote_example(%(what's your "name"))
    quote_example(1)
    quote_example(1.0)
  end
end

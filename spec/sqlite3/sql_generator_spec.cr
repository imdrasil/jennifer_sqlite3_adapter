require "../spec_helper"

def build_expression
  Jennifer::QueryBuilder::ExpressionBuilder.new("table")
end

def build_criteria
  Jennifer::QueryBuilder::Criteria.new("f1", "tests")
end

describe Jennifer::SQLite3::SQLGenerator do
  described_class = Jennifer::SQLite3::SQLGenerator

  describe ".insert" do
    it do
      described_class.insert(User.build({name: "User"}))
        .should eq("INSERT INTO users(name, age, admin, created_at, updated_at) VALUES (%s, %s, %s, %s, %s) ")
    end
  end

  describe ".update" do
    it do
      described_class.update(User.all, { "name" => "Peter" }).should eq("UPDATE users SET name = %s ")
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
        build_criteria.asc.as_sql.should eq("tests.f1 ASC")
        build_criteria.desc.as_sql.should eq("tests.f1 DESC")
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
end

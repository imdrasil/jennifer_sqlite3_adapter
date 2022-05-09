require "../spec_helper"

describe SQLite3::ResultSet do
  describe "#read" do
    FeatureHelper.with_json_support do
      it "accepts JSON" do
        User.create!({
          name:      "User",
          interests: JSON.parse(%({"likes": ["skating", "reading", "swimming"]})),
        })
        executed = false
        User.all.each_result_set do |rs|
          rs.columns.each do |column|
            next rs.read if column != "interests"

            result = rs.read(JSON::Any)
            result.should be_a(JSON::Any)
            result["likes"].as_a.should eq(["skating", "reading", "swimming"])
          end
          executed = true
        end
        executed.should be_true
      end

      it "accepts JSON?" do
        User.create!({
          name:      "User",
          interests: JSON.parse(%({"likes": ["skating", "reading", "swimming"]})),
        })
        executed = false
        User.all.each_result_set do |rs|
          rs.columns.each do |column|
            next rs.read if column != "interests"

            result = rs.read(JSON::Any?)
            result.should be_a(JSON::Any)
            result.not_nil!["likes"].as_a.should eq(["skating", "reading", "swimming"])
          end
          executed = true
        end
        executed.should be_true
      end

      it "accepts JSON? with nil value" do
        User.create!({name: "User", interests: nil})
        executed = false
        User.all.each_result_set do |rs|
          rs.columns.each do |column|
            next rs.read if column != "interests"

            result = rs.read(JSON::Any?)
            result.should be_nil
          end
          executed = true
        end
        executed.should be_true
      end
    end
  end
end

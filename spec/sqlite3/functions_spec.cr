require "../spec_helper"

describe "Jennifer::QueryBuilder SQL functions" do
  FeatureHelper.with_json_support do
    describe "json_extract" do
      it do
        user = User.create!({
          name:      "User",
          interests: JSON.parse(%({"likes": ["skating", "reading", "swimming"]})),
        })
        User.create!({name: "User2", interests: JSON.parse(%({"likes": ["reading", "skating", "swimming"]}))})
        User.where { json_extract(_interests, "$.likes[1]") == "reading" }.first!.id.should eq(user.id)
      end
    end

    describe "json_array_length" do
      it do
        user = User.create!({
          name:      "User",
          interests: JSON.parse(%({"likes": ["skating", "reading", "swimming"]})),
        })
        User.create!({name: "User2", interests: JSON.parse(%({"likes": ["skating", "swimming"]}))})
        User.where { json_array_length(_interests, "$.likes") == 3 }.first!.id.should eq(user.id)
      end
    end
  end
end

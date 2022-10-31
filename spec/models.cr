abstract class Model < Jennifer::Model::Base
  with_timestamps
end

module JSONField
  include Jennifer::Model::Mapping

  mapping(
    interests: JSON::Any?
  )
end

class User < Model
  FeatureHelper.with_json_support do
    include JSONField
  end

  mapping(
    id: Primary32,
    name: String,
    age: Int32?,
    admin: {type: Bool, default: false},
    created_at: Time?,
    updated_at: Time?
  )

  has_many :posts, Post

  def self.generate_list(count)
    count.times.map { |i| create!({name: "User #{i}", age: i}) }.to_a
  end
end

class Post < Model
  mapping(
    id: Primary32,
    title: String,
    text: String,
    user_id: Int32?,
    rating: {type: Float64, default: 0.0},
    created_at: Time?,
    updated_at: Time?
  )

  belongs_to :user, User
  has_many :comments, Comment

  def self.generate_list(count)
    count.times.map { |i| create!({title: "Post #{i}", text: "Text #{i}"}) }.to_a
  end
end

class Comment < Model
  mapping(
    id: Primary32,
    text: String,
    user_id: Int32?,
    post_id: Int32?,
    created_at: Time?,
    updated_at: Time?
  )

  belongs_to :user, User
  belongs_to :post, Post

  def self.generate_list(count)
    count.times.map { |i| create!({title: "Post #{i}", text: "Text #{i}"}) }.to_a
  end
end

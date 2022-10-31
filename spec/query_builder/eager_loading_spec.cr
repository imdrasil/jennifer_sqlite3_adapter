require "../spec_helper"

describe Jennifer::QueryBuilder::EagerLoading do
  describe "#eager_load" do
    it do
      user = User.create!({name: "user"})
      post = Post.create!({title: "title", text: "text", user_id: user.id})
      Comment.create({text: "comment", user_id: user.id, post_id: post.id})

      res = User.eager_load(posts: [:comments]).first!
      res.posts.size.should eq(1)
      res.posts[0].comments.size.should eq(1)
      res.posts[0].user_id.class.should eq(Int32)
      res.posts[0].comments[0].user_id.class.should eq(Int32)
      res.posts[0].comments[0].user_id.should eq(user.id)
    end
  end
end

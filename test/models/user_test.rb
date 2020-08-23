require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "lol@example.com",password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end
  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end
  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:activation,'')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end

  test "feed should have the right posts" do
    michael = users(:michael)
    archer = users(:archer)
    lana = users(:lana)
  # 关注的用户发布的微博
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end
  # 自己的微博
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
  # 未关注用户的微博
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
  # test "the truth" do
  #   assert true
  # end
end

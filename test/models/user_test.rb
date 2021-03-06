require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Renzo Solis", email: "rensolis@gmail.com", password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "should be present name" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "should be present email" do
    @user.email = ""
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

  test "email validation should accept valid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_email_case = "Foo@ExAMPle.CoM"
    @user.email = mixed_email_case
    @user.save
    assert_equal mixed_email_case.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember,'')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    renzo = users(:renzo)
    michael = users(:michael)
    assert_not renzo.following?(michael)
    renzo.follow(michael)
    assert renzo.following?(michael)
    assert michael.followers.include?(renzo)
    renzo.unfollow(michael)
    assert_not renzo.following?(michael)
  end

  test "feed should have the right posts" do
    renzo = users(:renzo)
    diana = users(:diana)
    carlo = users(:carlo)
    renzo.microposts.each do |post_self|
      assert renzo.feed.include?(post_self)
    end
    carlo.microposts.each do |post_following|
      assert renzo.feed.include?(post_following)
    end
    renzo.microposts.each do |post_unfollowed|
      assert_not diana.feed.include?(post_unfollowed)
    end
  end
end

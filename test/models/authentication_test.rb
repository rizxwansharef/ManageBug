require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @manager = User.create!(
      name: "Rizwan",
      email: "rizwan@m1.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: "manager"
    )
  end

  test "sign in with valid credentials" do
    sign_in @manager
    assert signed_in?(@manager), "User should be signed in"
  end

  test "sign out" do
    sign_in @manager
    sign_out @manager
    assert_not signed_in?(@manager), "User should be signed out"
  end
end

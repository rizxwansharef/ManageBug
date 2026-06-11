require "test_helper"

class UserTest < ActiveSupport::TestCase
  def test_user_requires_name
    user = User.new(name: nil, email: "unique-user@example.com", password: "Password123!", password_confirmation: "Password123!")
    assert_not user.save, "User should not be saved without a name"
  end

  def test_user_creation_without_email
    user = User.new(email: nil, name: "rizwan", password: "Password123!", password_confirmation: "Password123!")
    assert_not user.save, "User should not be saved without an email"
  end

  def test_user_creation_without_password
    user = User.new(name: "rizwan", email: "unique-password@example.com", password: nil, password_confirmation: nil)
    assert_not user.save, "User should not be saved without a password"
  end

  def test_user_creation_with_valid_attributes
    user = User.new(name: "rizwan", email: "unique-valid@example.com", password: "Password123@", password_confirmation: "Password123@", role: "manager")
    assert user.save, "User should be saved with valid attributes"
  end

  def test_user_creation_with_invalid_role
    user = User.new(name: "rizwan", email: "unique-role@example.com", password: "Password123@", password_confirmation: "Password123@", role: "random")
    assert_not user.save, "User should not be saved with an invalid role"
  end

  def test_password_validation
    user = User.new(name: "rizwan", email: "unique-password-rule@example.com", password: "123", password_confirmation: "123")
    assert_not user.save, "User should not be saved with an invalid password"
  end

  def test_email_format_validation
    user = User.new(name: "rizwan", email: "rizwan@email", password: "Password123@", password_confirmation: "Password123@", role: "manager")
    assert_not user.save, "User should not be saved with an invalid email format"
  end
end

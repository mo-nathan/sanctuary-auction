# frozen_string_literal: true

require 'test_helper'

class AdminTest < ActiveSupport::TestCase
  test 'cannot make more admins' do
    admin = Admin.create(email: 'foo@bar.com')
    assert_not(admin.save)
  end
end

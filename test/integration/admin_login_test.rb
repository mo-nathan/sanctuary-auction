# frozen_string_literal: true

require 'test_helper'

class AdminLoginTest < ActionDispatch::IntegrationTest
  test 'remember me checkbox shares a line with its label' do
    get new_admin_session_path
    assert_response :success
    assert_select 'div.field > input[type=checkbox]#admin_remember_me + label[for=admin_remember_me]'
  end
end

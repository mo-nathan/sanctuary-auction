# frozen_string_literal: true

require 'test_helper'

Capybara.enable_aria_label = true
# Bootstrap ignores clicks that land while a modal is still animating
Capybara.disable_animation = true

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
end

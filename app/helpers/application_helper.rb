# frozen_string_literal: true

module ApplicationHelper
  def class_from_type(type)
    type == 'notice' ? 'success' : 'danger'
  end
end

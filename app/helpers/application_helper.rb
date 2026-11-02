# frozen_string_literal: true

module ApplicationHelper
  def class_from_type(type)
    type == 'notice' ? 'success' : 'danger'
  end

  # The field_error_proc initializer points invalid fields at these messages
  def field_errors(form, attribute)
    messages = form.object.errors.full_messages_for(attribute)
    return if messages.empty?

    tag.div(id: form.field_id(attribute, :error)) { safe_join(messages.map { |message| tag.div(message) }) }
  end
end

# frozen_string_literal: true

# Marks invalid fields for screen readers and points them at their messages,
# which field_errors renders with the field's id plus "_error".
Rails.application.config.action_view.field_error_proc = proc do |html_tag, _instance|
  fragment = Nokogiri::HTML5::DocumentFragment.parse(html_tag)
  field = fragment.at_css('input, textarea, select')
  if field && field['id'] && field['type'] != 'hidden'
    field['aria-invalid'] = 'true'
    field['aria-describedby'] = "#{field['id']}_error"
  end
  # The fragment is the already-escaped field Rails passed in
  ActionController::Base.helpers.tag.div(fragment.to_html.html_safe, class: 'field_with_errors') # rubocop:disable Rails/OutputSafety
end

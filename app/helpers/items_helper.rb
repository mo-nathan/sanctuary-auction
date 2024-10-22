# frozen_string_literal: true

module ItemsHelper
  def format_with_breaks(text)
    result = ''.html_safe
    if text
      first = true
      text.split("\n").each do |s|
        result += tag.br unless first
        first = false
        result += s
      end
    end
    result
  end
end

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

  # Names the item for screen readers, since every item has the same link text
  def item_link(label, item)
    link_to(item_path(item), class: 'mb-2 btn btn-default btn-lg bg-info-subtle') do
      safe_join([label, tag.span(" for #{item.title}", class: 'visually-hidden')])
    end
  end
end

# frozen_string_literal: true

# lib/tasks/resolve_image_urls.rb

# Replaces imgur page links on existing items with direct image links.
# Safe to run more than once.
# Usage: rails runner lib/tasks/resolve_image_urls.rb
Item.unscoped.where.not(image_url: [nil, '']).find_each do |item|
  resolved = ImageUrlResolver.resolve(item.image_url)
  next if resolved == item.image_url

  if item.update(image_url: resolved)
    Rails.logger.info "#{item.title}: #{resolved}"
  else
    Rails.logger.error "#{item.title}: #{item.errors.full_messages.to_sentence}"
  end
end

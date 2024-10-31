# frozen_string_literal: true

require 'csv'

class Tagger
  COLUMN_TO_TAG = {
    'Activity' => ['Category', 'Activities & Experiences'],
    'Artwork' => ['Category', 'Artwork, Music, and Crafts'],
    'Auction' => ['Other Tags', 'Auction'],
    'Buyin' => ['Other Tags', 'Buy-In'],
    'Event_Hybrid' => ['Format', 'Event: Hybrid'],
    'Event_InPerson' => ['Format', 'Event: In Person'],
    'Event_Virtual' => ['Format', 'Event: Virtual'],
    'Family' => ['Other Tags', 'Family Friendly'],
    'Food' => %w[Category Food],
    'GroupEvent' => ['Category', 'Group Events'],
    'Object_Deliver' => ['Format', 'Item: Delivered'],
    'Object_Mail' => ['Format', 'Item: Mailed'],
    'Service' => %w[Category Services]
  }.freeze

  def self.create_tags
    Tag.destroy_all
    COLUMN_TO_TAG.each_value do |group, name|
      Tag.find_or_create_by(group:, name:)
    end
  end

  def self.update_tags(item, row)
    row.each_entry do |key, value|
      next unless COLUMN_TO_TAG.include?(key)

      group, name = COLUMN_TO_TAG[key]
      tag = Tag.find_by(group:, name:)
      update_tag(item, tag, value == '1 - Yes')
    end
  end

  def self.auction_tag
    Tag.find_by(name: 'Auction')
  end

  def self.update_tag(item, tag, include)
    return unless tag

    return unless include

    item.tags << tag unless item.tags.include?(tag)
  end
end

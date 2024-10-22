# frozen_string_literal: true

# lib/tasks/import_items.rb

require 'csv'

class ImportItems
  COLUMN_TO_TAG = {
    'Activity' => 'Activities & Experiences',
    'Artwork' => 'Artwork, Music, and Crafts',
    'Buyin' => 'Buy-In',
    'Event_Hybrid' => 'Event: Hybrid',
    'Event_InPerson' => 'Event: In Person',
    'Event_Virtual' => 'Event: Virtual',
    'Family' => 'Family Friendly',
    'Food' => 'Food',
    'GroupEvent' => 'Group Events',
    'Object_Deliver' => 'Item: Delivered',
    'Object_Mail' => 'Item: Mailed',
    'Service' => 'Services'
  }.freeze

  def self.import_from_csv(file_path)
    unless File.exist?(file_path)
      Rails.logger.debug { "File not found: #{file_path}" }
      return
    end

    File.open(file_path) do |file|
      CSV.foreach(file, headers: true) do |row|
        # Create Item object from each row in the CSV
        item_from_row(row)
      end
    end
  end

  def self.create_item(row)
    item_attributes = build_item_attributes(row)
    result = Item.create(item_attributes)
    if result
      Rails.logger.debug { "Successfully created Item: #{item.title} from #{item.host}" }
    else
      Rails.logger.debug { "Unable to create item: #{row}" }
    end
    result
  end

  def self.build_item_attributes(row)
    {
      description: calc_description(row),
      cost: calc_cost(row),
      number: row['Number'],
      image_url: row['Image'],
      title: row['Title'],
      host: row['Host'],
      timing: row['Time'],
      format: 'Deprecated'
    }
  end

  def self.calc_description(row)
    start = row['Description'] || ''
    return start unless row['Details']

    "#{start}\n\n#{row['Details']}"
  end

  def self.calc_cost(row)
    return 10 if row.include?('Buyin') == '1 - Yes'

    nil
  end

  def self.item_from_row(row)
    item = Item.find_by(host: row['Host'], title: row['Title'])
    if item
      update_item(item, row)
    else
      item = create_item(row)
    end
    update_tags(item, row)
  end

  def self.update_item(item, row)
    item.description = calc_description(row)
    item.image_url = row['Image']
    item.cost = calc_cost(row)
    item.number = row['Number']
    item.timing = row['Time']
    item.format = 'Deprecated'
    Rails.logger.debug { "Successfully updated Item: #{item.title} from #{item.host}" }
  end

  def self.update_tags(item, row)
    row.each_key do |key|
      next unless COLUMN_TO_TAG.include?(key)

      tag = Tag.find_by(name: COLUMN_TO_TAG[key])
      next unless tag

      if row[key] == '1 - Yes'
        item.tags << tag unless item.tags.include?(tag)
      elsif item.tags.include?(tag)
        item.tags.delete(tag)
      end
    end
  end
end

# Accept the CSV file path from the command line arguments
if ARGV.length == 1
  file_path = ARGV[0]
  ImportItems.import_from_csv(file_path)
else
  Rails.logger.debug 'Usage: rails runner lib/tasks/import_items.rb <path_to_csv_file>'
end

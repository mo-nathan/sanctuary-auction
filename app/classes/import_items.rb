# frozen_string_literal: true

require 'csv'

class ImportItems
  def self.import_from_csv(file_path)
    unless File.exist?(file_path)
      Rails.logger.debug { "File not found: #{file_path}" }
      return
    end

    Tagger.create_tags
    load_items(file_path)
  end

  def self.load_items(file_path)
    Item.destroy_all
    File.open(file_path) do |file|
      count = 0
      CSV.foreach(file, headers: true) do |row|
        # Create Item object from each row in the CSV
        item_from_row(row)
        count += 1
      end
    end
  end

  def self.create_item(row)
    item_attributes = build_item_attributes(row)
    report_on_result(Item.create(item_attributes), row)
  end

  def self.report_on_result(result, row)
    if result
      Rails.logger.debug { "Successfully created Item: #{result.title} from #{result.host}" }
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
      auction: row['Live auction?'] == 'Yes'
    }
  end

  def self.calc_description(row)
    start = row['Description'] || ''
    return start unless row['Details']

    "#{start}\n\n#{row['Details']}"
  end

  def self.calc_cost(row)
    return 1 if row['Buyin'] == '1 - Yes'

    nil
  end

  def self.item_from_row(row)
    item = create_item(row)
    Tagger.update_tags(item, row)
  end
end

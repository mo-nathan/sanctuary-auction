# frozen_string_literal: true

# lib/tasks/import_items.rb

# Accept the CSV file path from the command line arguments
if ARGV.length == 1
  file_path = ARGV[0]
  Tagger.create_tags
  ImportItems.import_from_csv(file_path)
else
  Rails.logger.debug 'Usage: rails runner lib/tasks/import_items.rb <path_to_csv_file>'
end

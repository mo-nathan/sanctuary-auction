# frozen_string_literal: true

# Accept the CSV file path from the command line arguments
Rails.logger = ActiveSupport::Logger.new($stdout)
Rails.logger.level = Logger::DEBUG # Set to DEBUG level, or another level as needed

ItemAllocator.new.report

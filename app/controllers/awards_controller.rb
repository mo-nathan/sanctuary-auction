# frozen_string_literal: true

require 'csv'

class AwardsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @award_files = list_award_files
  end

  def create
    allocator = ItemAllocator.new
    results = allocator.report
    csv_content = generate_csv(results)
    filename = generate_filename

    save_csv(csv_content, filename)
    redirect_to awards_path, flash: { download_filename: filename }
  end

  def download
    filename = params[:filename]
    return head :forbidden if invalid_filename?(filename)

    filepath = awards_directory.join(filename)
    send_award_file(filepath, filename)
  end

  def destroy
    filename = params[:filename]
    return head :forbidden if invalid_filename?(filename)

    filepath = awards_directory.join(filename)
    delete_award_file(filepath)
  end

  private

  def awards_directory
    Rails.root.join('tmp/awards')
  end

  def invalid_filename?(filename)
    filename.include?('..') || filename.include?('/')
  end

  def send_award_file(filepath, filename)
    if File.exist?(filepath)
      send_file filepath, filename:, type: 'text/csv', disposition: 'attachment'
    else
      redirect_to awards_path, alert: t('awards.file_not_found')
    end
  end

  def delete_award_file(filepath)
    if File.exist?(filepath)
      File.delete(filepath)
      redirect_to awards_path, notice: t('awards.file_deleted')
    else
      redirect_to awards_path, alert: t('awards.file_not_found')
    end
  end

  def generate_filename
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    "awards_#{timestamp}.csv"
  end

  def save_csv(csv_content, filename)
    filepath = awards_directory.join(filename)
    FileUtils.mkdir_p(awards_directory)
    File.write(filepath, csv_content)
  end

  def list_award_files
    return [] unless File.directory?(awards_directory)

    Dir.glob(awards_directory.join('awards_*.csv'))
       .map { |path| File.basename(path) }
       .sort
       .reverse
  end

  def generate_csv(results)
    CSV.generate do |csv|
      csv << %w[Winner Item Host]
      results.each do |row|
        csv << row
      end
    end
  end
end

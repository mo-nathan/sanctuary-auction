# frozen_string_literal: true

require 'csv'

class ItemsCsvController < ApplicationController
  before_action :authenticate_admin!

  def new
    # Just render the upload form
  end

  def preview
    uploaded_file = params[:csv_file]
    return redirect_to_upload_with_alert(t('items.csv.no_file')) if uploaded_file.blank?

    temp_path = save_uploaded_csv(uploaded_file)
    count_csv_items(temp_path)
  end

  def create
    temp_path = session[:csv_temp_path]
    return redirect_to_upload_with_alert(t('items.csv.no_temp_file')) if csv_temp_file_missing?(temp_path)

    perform_import(temp_path)
  end

  private

  def redirect_to_upload_with_alert(message)
    redirect_to new_items_csv_path, alert: message
  end

  def save_uploaded_csv(uploaded_file)
    temp_path = Rails.root.join('tmp', 'uploads', "items_import_#{Time.now.to_i}.csv")
    FileUtils.mkdir_p(File.dirname(temp_path))
    File.binwrite(temp_path, uploaded_file.read)
    temp_path
  end

  def count_csv_items(temp_path)
    @item_count = CSV.read(temp_path, headers: true).length
    session[:csv_temp_path] = temp_path.to_s
  rescue StandardError => e
    FileUtils.rm_f(temp_path)
    redirect_to_upload_with_alert(t('items.csv.read_error', message: e.message))
    nil
  end

  def csv_temp_file_missing?(temp_path)
    temp_path.blank? || !File.exist?(temp_path)
  end

  def perform_import(temp_path)
    ImportItems.import_from_csv(temp_path)
    cleanup_csv_import(temp_path)
    redirect_to items_path, notice: t('items.csv.import_success')
  rescue StandardError => e
    redirect_to_upload_with_alert(t('items.csv.import_error', message: e.message))
  end

  def cleanup_csv_import(temp_path)
    File.delete(temp_path)
    session.delete(:csv_temp_path)
  end
end

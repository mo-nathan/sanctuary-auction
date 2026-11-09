# frozen_string_literal: true

class Bid < ApplicationRecord
  REPORT_NAME = 'bids.csv'
  belongs_to :user
  belongs_to :item

  def join
    amount&.zero? ? '0' : '1'
  end

  # Writes to the working directory by default, which is the app root in a
  # console and /rails in the container.
  def self.report(path = REPORT_NAME)
    File.open(path, 'w') do |file|
      file.write("User Name\tUser Code\tBid Amount\tItem Type\tItem Number\tItem Title\n")
      Bid.find_each do |bid|
        file.write("#{bid.user.name}\t#{bid.user.code}\t#{bid.amount}\t#{bid.item.item_type}\t" \
                   "#{bid.item.number}\t#{bid.item.title}\n")
      end
    end
  end
end

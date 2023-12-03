# frozen_string_literal: true

class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :item

  def join
    amount&.zero? ? '0' : '1'
  end

  def self.report
    File.open('bids.csv', 'w') do |file|
      file.write("User Name\tUser Code\tBid Amount\tItem Type\tItem Number\tItem Title\n")
      Bid.all.find_each do |bid|
        file.write("#{bid.user.name}\t#{bid.user.code}\t#{bid.amount}\t#{bid.item.item_type}\t#{bid.item.number}\t#{bid.item.title}\n")
      end
    end
  end
end

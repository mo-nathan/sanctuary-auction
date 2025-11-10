# frozen_string_literal: true

class ItemAllocator
  def initialize
    init_item_statuses
    @user_assignments = {}
    @users = User.all.to_a
    @user_queue = []
  end

  def init_item_statuses
    @item_statuses = {}
    Item.joins(:bids).where(cost: nil).distinct.each do |item|
      @item_statuses[item] = item.number unless item.number.nil?
    end
  end

  def next_user
    @user_queue = @users.dup.shuffle if @user_queue == []
    user = @user_queue.pop
    Rails.logger.info "Assigning an item to #{user.name}" if user
    user
  end

  def items_with_no_bids
    Item.where.missing(:bids).find_each do |item|
      Rails.logger.info "The item, #{item.title}, from #{item.host} has no bids."
    end
  end

  def report
    items_with_no_bids
    @item_statuses ||= ItemStatus.initial_list

    assign_item_to_users
    assign_unlimited_items
    output_report
  end

  def assign_unlimited_items
    Item.where.not(cost: nil).find_each do |item|
      item.bids.each do |bid|
        update_user_assignments(item, bid.user)
      end
    end
  end

  def assign_item_to_users
    while @item_statuses.any?
      user = next_user
      break unless user

      @users.delete(user) unless find_item_for_user(user)
    end
  end

  def output_report
    result = []
    Rails.logger.info 'Winner,Item,Host'
    @user_assignments.each do |key, value|
      winner = key.name
      value.each do |item|
        Rails.logger.info "#{winner},\"#{item.title}\",#{item.host}"
        result.append([key.name, item.title, item.host])
      end
    end
    result
  end

  def find_item_for_user(user)
    selector = ItemSelector.new
    user.bids.find_each do |bid|
      next unless available?(user, bid.item)

      selector.consider(bid)
    end
    item = selector.sample
    assign(item, user) if item
    item
  end

  def available?(user, item)
    return false if @user_assignments[user]&.include?(item)

    @item_statuses.include?(item)
  end

  def assign(item, user)
    update_user_assignments(item, user)
    update_item_status(item)
  end

  def update_user_assignments(item, user)
    assignments = @user_assignments[user]
    if assignments
      @user_assignments[user].append(item)
    else
      @user_assignments[user] = [item]
    end
  end

  def update_item_status(item)
    count = @item_statuses[item]
    if count && count > 1
      @item_statuses[item] = count - 1
    else
      @item_statuses.delete(item)
    end
  end
end

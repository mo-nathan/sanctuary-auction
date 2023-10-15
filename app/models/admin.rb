# frozen_string_literal: true

class Admin < ApplicationRecord
  validate :admin_check

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def admin_check
    return unless Admin.all.size.positive?

    errors.add(:base, 'There Can Be Only One (Admin)')
  end
end

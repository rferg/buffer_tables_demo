# frozen_string_literal: true

class BusinessEvent < ApplicationRecord
  scope :unclaimed, -> { where(group_id: nil) }
  scope :claimed_group, ->(group_id) { includes(:business_thing).where(group_id:) }

  belongs_to :business_thing

  class << self
    def add!(business_thing)
      create!(business_thing:, action: 'test')
    end

    def claim(limit)
      raise ArgumentError, 'block required' unless block_given?

      transaction do
        ids = unclaimed.lock('FOR UPDATE SKIP LOCKED').limit(limit).pluck(:id)
        if ids.present?
          group_id = SecureRandom.uuid
          BusinessEvent.where(id: ids).update_all(group_id:)
          yield(group_id)
        end
        ids
      end
    end

    def complete_group(group_id)
      where(group_id:).delete_all
    end
  end
end

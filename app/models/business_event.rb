# frozen_string_literal: true

class BusinessEvent < ApplicationRecord
  scope :unprocessed, -> { where(group_id: nil) }

  belongs_to :business_thing

  class << self
    def add!(biz_thing)
      create!(business_things_id: biz_thing.id, action: 'test')
    end

    def enqueue_next(limit)
      raise ArgumentError, 'block required' unless block_given?

      transaction do
        group = unprocessed.lock('FOR UPDATE SKIP LOCKED').limit(limit)
        yield(assign_group(group))
      end
    end

    private

    def assign_group(group)
      SecureRandom.uuid.tap do |group_id|
        BusinessEvent.where(id: group.pluck(:id)).update_all(group_id:)
      end
    end
  end
end

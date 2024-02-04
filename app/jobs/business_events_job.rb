# frozen_string_literal: true

class BusinessEventsJob
  include Sidekiq::Job

  def perform(group_id)
    records = BusinessEvent.includes(:business_thing).where(group_id:)
    puts records.size
    # do stuff
    BusinessEvent.where(group_id:).delete_all
  end
end

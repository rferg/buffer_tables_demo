# frozen_string_literal: true

class BusinessEventsJob
  include Sidekiq::Job
  sidekiq_options retry: 2

  sidekiq_retries_exhausted do |msg|
    group_id = msg['args'].first
    BusinessEvent.complete_group(group_id)
    Rails.logger.error("BusinessEvent group #{group_id} exhausted retries: #{msg['error_message']}")
  end

  def perform(group_id)
    events = BusinessEvent.claimed_group(group_id)

    do_stuff(events)

    BusinessEvent.complete_group(group_id)
  end

  private

  def do_stuff(events)
    added_count = BusinessEventsCounter.add(events)

    raise "Expected to add #{events.size} but only added #{added_count}" if added_count < events.size
  end
end

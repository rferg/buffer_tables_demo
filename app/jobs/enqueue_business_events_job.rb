# frozen_string_literal: true

class EnqueueBusinessEventsJob
  include Sidekiq::Job

  def perform
    BusinessEvent.enqueue_next(Rails.configuration.buffer_batch_size) do |group_id|
      BusinessEventsJob.perform_async(group_id)
    end
  end
end

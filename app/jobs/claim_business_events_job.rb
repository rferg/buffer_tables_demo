# frozen_string_literal: true

class ClaimBusinessEventsJob
  include Sidekiq::Job

  def perform
    BusinessEvent.claim(batch_size) { |group_id| BusinessEventsJob.perform_async(group_id) }
  end

  private

  def batch_size
    Rails.configuration.buffer_batch_size
  end
end

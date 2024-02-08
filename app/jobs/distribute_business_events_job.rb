# frozen_string_literal: true

class DistributeBusinessEventsJob
  include Sidekiq::Job

  def perform
    count = BusinessEvent.unclaimed.count
    args = (count / batch_size.to_f).ceil.times.map { [] }
    ClaimBusinessEventsJob.perform_bulk(args)
  end

  private

  def batch_size
    Rails.configuration.buffer_batch_size
  end
end

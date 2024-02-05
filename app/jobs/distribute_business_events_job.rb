# frozen_string_literal: true

class DistributeBusinessEventsJob
  include Sidekiq::Job

  def perform
    count = BusinessEvent.unclaimed.count
    args = (count / Rails.configuration.buffer_batch_size.to_f).ceil.times.map { [] }
    EnqueueBusinessEventsJob.perform_bulk(args)
  end
end

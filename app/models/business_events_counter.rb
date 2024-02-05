# frozen_string_literal: true

class BusinessEventsCounter
  class << self
    def add(events)
      new.add(events)
    end

    def count
      new.count
    end

    def clear
      new.clear
    end
  end

  def initialize(key = Rails.configuration.business_events_set_key)
    @key = key
  end

  def add(events)
    return 0 if events.blank?

    App.redis.sadd(key, *events.map { |e| e.id.to_s })
  end

  def count
    App.redis.scard(key)
  end

  def clear
    App.redis.del(key)
  end

  private

  attr_reader :key
end

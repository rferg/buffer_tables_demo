# frozen_string_literal: true

require 'connection_pool'

module App
  def self.redis
    @redis ||= ConnectionPool::Wrapper.new { Redis.new }
  end
end

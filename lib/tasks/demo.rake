# frozen_string_literal: true

module Demo
  def self.insert_n_events(num)
    sql = <<~SQL
      INSERT INTO business_events (business_thing_id, "action", created_at, updated_at)
      SELECT b.id, 'test', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM (SELECT id FROM business_things LIMIT 1) as b(id)
      CROSS JOIN generate_series(1, #{num})
    SQL

    puts Rainbow(sql).white
    ActiveRecord::Base.connection.execute(sql)
  end
end

namespace :demo do
  desc 'single run'
  task :single, [:number] => [:environment] do |_t, args|
    n = args[:number]&.to_i

    raise 'Usage: rake demo:single[1000]' unless n.present?
    raise 'Number must be positive integer' unless n.positive?

    pre_existing_count = BusinessEvent.unclaimed.count
    puts Rainbow("Found #{pre_existing_count} unclaimed events.").white

    Demo.insert_n_events(n)
    puts Rainbow("Inserted #{n} more events.").white

    begin
      start = Time.current
      DistributeBusinessEventsJob.perform_async
      puts Rainbow('Enqueued DistributeBusinessEventsJob.').white

      expected_count = pre_existing_count + n
      max_iterations = 120
      iterations = 0
      current_count = 0
      while current_count < expected_count && iterations < max_iterations
        current_count = BusinessEventsCounter.count

        puts Rainbow("Events processed: #{current_count}.").cyan

        sleep(1)
        iterations += 1
      end
      elapsed = Time.current - start
      rate = current_count / elapsed

      puts Rainbow("Processed all #{current_count} events.").green if current_count >= expected_count

      puts Rainbow("Hit max iterations #{max_iterations}.").red if iterations >= max_iterations

      puts Rainbow("#{elapsed.round(2)} s, #{rate.round(2)} events/sec").yellow
    ensure
      BusinessEventsCounter.clear
      puts Rainbow("Found #{BusinessEvent.unclaimed.count} unclaimed events remaining.")
    end
  end
end

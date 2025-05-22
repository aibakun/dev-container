namespace :benchmark do
  desc 'Comparison of date search speed with 1 million records (with index vs without index)'
  task date_search: :environment do
    require 'benchmark'

    puts '========================================='
    puts '  Comparison of date search speed with 1 million records'
    puts '========================================='

    puts "\n1. Preparing test data"
    Event.delete_all
    unless User.exists?(1)
      User.create!(
        id: 1,
        name: 'Test User',
        email: 'shoki.surface@gmail.com',
        password_digest: 'test',
        occupation: 0
      )
    end

    puts "\n2. Generating 1 million records"
    batch_size = 10_000
    total_records = 1_000_000
    base_time = Time.current

    Benchmark.bm do |benchmark|
      benchmark.report do
        (0...total_records).step(batch_size) do |batch_start|
          bulk_records = batch_size.times.map do |index|
            current_position = batch_start + index
            start_time = base_time - 365.days + rand(730).days

            {
              title: "Event #{current_position}",
              start_at: start_time,
              end_at: start_time + rand(1..48).hours,
              user_id: 1,
              created_at: Time.current,
              updated_at: Time.current
            }
          end

          Event.insert_all!(bulk_records)
          progress = ((batch_start + batch_size) * 100.0 / total_records).round(1)
          print "\rProgress: #{[progress, 100.0].min}%"
        end
      end
    end

    puts "\n\n3. Updating statistics"
    ActiveRecord::Base.connection.execute('ANALYZE events')

    target_date = base_time - 180.days

    puts "\n4. Comparing search speed"
    puts "\n■ Search with index (start_at)"
    puts ActiveRecord::Base.connection.execute("
      EXPLAIN ANALYZE
      SELECT * FROM events
      WHERE start_at >= '#{target_date}'
      ORDER BY start_at ASC
      LIMIT 1000
    ").map { |record| record['QUERY PLAN'] }.join("\n")

    puts "\n■ Search without index (end_at)"
    puts ActiveRecord::Base.connection.execute("
      EXPLAIN ANALYZE
      SELECT * FROM events
      WHERE end_at >= '#{target_date}'
      LIMIT 1000
    ").map { |record| record['QUERY PLAN'] }.join("\n")

    puts "\n5. Actual search time (average of 100 executions)"
    Benchmark.bm(25) do |benchmark|
      benchmark.report('With index (start_at):') do
        100.times do
          Event.where('start_at >= ?', target_date)
               .order(start_at: :asc)
               .limit(1000)
               .to_a
        end
      end

      benchmark.report('Without index (end_at):  ') do
        100.times do
          Event.where('end_at >= ?', target_date)
               .limit(1000)
               .to_a
        end
      end
    end

    puts "\n6. Table information"
    table_stats = ActiveRecord::Base.connection.execute("
      SELECT
        pg_size_pretty(pg_total_relation_size('events')) as total_size,
        pg_size_pretty(pg_table_size('events')) as table_size,
        pg_size_pretty(pg_indexes_size('events')) as index_size,
        (SELECT count(*) FROM events) as total_records,
        (SELECT count(*) FROM events WHERE start_at >= '#{target_date}') as matching_records
    ").first

    puts '----------------------------------------'
    puts "Total size:          #{table_stats['total_size']}"
    puts "Table size:          #{table_stats['table_size']}"
    puts "Index size:          #{table_stats['index_size']}"
    puts "Total records:       #{table_stats['total_records']}"
    puts "Matching records:    #{table_stats['matching_records']}"
    puts '----------------------------------------'

    puts "\n7. Search conditions"
    puts "Search date: #{target_date}"
    puts '----------------------------------------'
  end
end

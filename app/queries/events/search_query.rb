module Events
  class SearchQuery
    def initialize(records = Event.all)
      @records = records
    end

    def call(params)
      base_records
        .then { |records| filter_by_title(records, params[:title]) }
        .then { |records| filter_by_location(records, params[:location]) }
        .then { |records| filter_by_date_range(records, params[:start_date], params[:end_date]) }
        .then { |records| filter_by_user(records, params[:user_id]) }
    end

    private

    def valid_date?(date)
      date.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/)
    end

    def base_records
      @records.preload(:user).order(start_at: :asc)
    end

    def filter_by_title(records, title)
      return records if title.blank?

      escaped_title = ActiveRecord::Base.sanitize_sql_like(title.to_s.strip)
      records.where('title ILIKE :query', query: "%#{escaped_title}%")
    end

    def filter_by_location(records, location)
      return records if location.blank?

      escaped_location = ActiveRecord::Base.sanitize_sql_like(location.to_s.strip)
      records.where('location ILIKE :query', query: "%#{escaped_location}%")
    end

    def filter_by_date_range(records, start_date, end_date)
      records
        .then { |records| filter_by_start_date(records, start_date) }
        .then { |records| filter_by_end_date(records, end_date) }
    end

    def filter_by_user(records, user_id)
      return records if user_id.blank?
      return records unless user_id.to_s.match?(/\A\d+\z/)

      records.where(user_id: user_id)
    end

    def filter_by_start_date(records, date)
      return records unless date.present?
      return records unless valid_date?(date)

      begin
        start_time = Time.zone.parse(date.to_s).beginning_of_day
        records.where('start_at >= ?', start_time)
      rescue ArgumentError
        records
      end
    end

    def filter_by_end_date(records, date)
      return records unless date.present?
      return records unless valid_date?(date)

      begin
        end_time = Time.zone.parse(date.to_s).end_of_day
        records.where('end_at <= ?', end_time)
      rescue ArgumentError
        records
      end
    end
  end
end

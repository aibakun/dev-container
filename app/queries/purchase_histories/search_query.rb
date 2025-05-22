module PurchaseHistories
  class SearchQuery
    def initialize(records = PurchaseHistory.all)
      @records = records
    end

    def call(params)
      base_records
        .then { |records| filter_by_name(records, params[:name]) }
        .then { |records| filter_by_price_range(records, params[:min_price], params[:max_price]) }
        .then { |records| filter_by_date_range(records, params[:start_date], params[:end_date]) }
        .then { |records| filter_by_user(records, params[:user_id]) }
    end

    private

    def base_records
      @records.preload(:user).order(purchase_date: :desc)
    end

    def valid_date?(date)
      date.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/)
    end

    def filter_by_name(records, name)
      return records if name.blank?

      escaped_name = ActiveRecord::Base.sanitize_sql_like(name.to_s.strip)
      records.where('name ILIKE :query', query: "%#{escaped_name}%")
    end

    def filter_by_price_range(records, min_price, max_price)
      records = records.where('price >= ?', min_price) if min_price.present?
      records = records.where('price <= ?', max_price) if max_price.present?
      records
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
        records.where('purchase_date >= ?', start_time)
      rescue ArgumentError
        records
      end
    end

    def filter_by_end_date(records, date)
      return records unless date.present?
      return records unless valid_date?(date)

      begin
        end_time = Time.zone.parse(date.to_s).end_of_day
        records.where('purchase_date <= ?', end_time)
      rescue ArgumentError
        records
      end
    end
  end
end

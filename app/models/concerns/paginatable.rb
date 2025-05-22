module Paginatable
  extend ActiveSupport::Concern

  module ClassMethods
    def page(page_number, per_page = 10)
      page = [page_number.to_i, 1].max
      limit(per_page).offset((page - 1) * per_page)
    end

    def total_pages(per_page = 10)
      (count.to_f / per_page).ceil
    end

    def page_range(current_page, total_pages, window = 2)
      start_page = [1, current_page - window].max
      end_page = [total_pages, current_page + window].min
      (start_page..end_page).to_a
    end
  end
end

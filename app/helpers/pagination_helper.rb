module PaginationHelper
  def pagination_links(current_page, total_pages, path_helper)
    return if total_pages <= 1

    content_tag(:ul, class: 'pagination') do
      links = []
      links << prev_page_link(current_page, path_helper)
      links.concat(page_links(current_page, total_pages, path_helper))
      links << next_page_link(current_page, total_pages, path_helper)
      safe_join(links)
    end
  end

  private

  def prev_page_link(current_page, path_helper)
    content_tag(:li, class: "page-item #{current_page <= 1 ? 'disabled' : ''}") do
      if current_page <= 1
        link_to('«', '#', class: 'page-link', tabindex: -1)
      else
        link_to('«', send(path_helper, page: current_page - 1), class: 'page-link')
      end
    end
  end

  def next_page_link(current_page, total_pages, path_helper)
    content_tag(:li, class: "page-item #{current_page >= total_pages ? 'disabled' : ''}") do
      if current_page >= total_pages
        link_to('»', '#', class: 'page-link', tabindex: -1)
      else
        link_to('»', send(path_helper, page: current_page + 1), class: 'page-link')
      end
    end
  end

  def page_links(current_page, total_pages, path_helper)
    User.page_range(current_page, total_pages).map do |page|
      content_tag(:li, class: "page-item #{page == current_page ? 'active' : ''}") do
        if page == current_page
          link_to(page, '#', class: 'page-link')
        else
          link_to(page, send(path_helper, page: page), class: 'page-link')
        end
      end
    end
  end
end

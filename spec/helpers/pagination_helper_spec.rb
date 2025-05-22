require 'rails_helper'

RSpec.describe PaginationHelper, type: :helper do
  describe '#pagination_links' do
    let(:path_helper) { :test_path }

    before do
      helper.define_singleton_method(:test_path) do |options = {}|
        "/test?#{options.to_query}"
      end
    end

    it 'generates correct links for middle pages' do
      result = helper.pagination_links(3, 5, path_helper)
      expect(result).to include('page-item')
      expect(result).to include('«')
      expect(result).to include('»')
    end

    it 'does not include prev link on first page' do
      result = helper.pagination_links(1, 5, path_helper)
      expect(result).to include('page-item')
      expect(result).to include('page-item disabled')
    end

    it 'does not include next link on last page' do
      result = helper.pagination_links(5, 5, path_helper)
      expect(result).to include('page-item')
      expect(result).to include('page-item disabled')
    end

    it 'limits the number of displayed pages' do
      result = helper.pagination_links(5, 10, path_helper)
      expect(result).to include('3')
      expect(result).to include('4')
      expect(result).to include('5')
      expect(result).to include('6')
      expect(result).to include('7')
      expect(result).not_to include('2')
      expect(result).not_to include('8')
    end
  end
end

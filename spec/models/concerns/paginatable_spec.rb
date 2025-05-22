require 'rails_helper'

RSpec.describe Paginatable do
  before(:all) do
    class TestModel
      include Paginatable
      def self.count; end
      def self.limit(*args); end
      def self.offset(*args); end
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestModel)
  end

  let(:model_class) { TestModel }

  before do
    allow(model_class).to receive(:count).and_return(100)
    allow(model_class).to receive(:limit).and_return(model_class)
    allow(model_class).to receive(:offset).and_return(model_class)
  end

  describe '.page' do
    it 'limits the number of records' do
      expect(model_class).to receive(:limit).with(10)
      model_class.page(1)
    end

    it 'offsets the records based on the page number' do
      expect(model_class).to receive(:offset).with(20)
      model_class.page(3)
    end

    it 'uses the first page if page number is less than 1' do
      expect(model_class).to receive(:offset).with(0)
      model_class.page(0)
    end

    it 'allows custom per_page value' do
      expect(model_class).to receive(:limit).with(20)
      expect(model_class).to receive(:offset).with(40)
      model_class.page(3, 20)
    end
  end

  describe '.total_pages' do
    it 'calculates the total number of pages' do
      expect(model_class.total_pages).to eq(10)
    end

    it 'calculates the total pages with custom per_page value' do
      expect(model_class.total_pages(25)).to eq(4)
    end

    it 'rounds up the number of pages' do
      allow(model_class).to receive(:count).and_return(101)
      expect(model_class.total_pages).to eq(11)
    end
  end
end

require 'rails_helper'

RSpec.describe Events::SearchQuery do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  let!(:event1) do
    create(:event, user: user, title: 'Ruby Conference', location: 'Tokyo', start_at: 1.day.from_now,
                   end_at: 2.days.from_now)
  end
  let!(:event2) do
    create(:event, user: user, title: 'Python Meetup', location: 'Osaka', start_at: 2.days.from_now,
                   end_at: 3.days.from_now)
  end
  let!(:event3) do
    create(:event, user: other_user, title: 'JavaScript Workshop', location: 'Tokyo', start_at: 3.days.from_now,
                   end_at: 4.days.from_now)
  end

  describe '#call' do
    it 'returns all events when no parameters are provided' do
      results = described_class.new.call({})
      expect(results).to match_array([event1, event2, event3])
    end

    it 'filters by title' do
      results = described_class.new.call(title: 'Ruby')
      expect(results).to contain_exactly(event1)
    end

    it 'filters by location' do
      results = described_class.new.call(location: 'Tokyo')
      expect(results).to contain_exactly(event1, event3)
    end

    it 'filters by date range' do
      results = described_class.new.call(
        start_date: 1.day.from_now.to_date.to_s,
        end_date: 2.days.from_now.to_date.to_s
      )
      expect(results).to contain_exactly(event1)
    end

    it 'filters by user' do
      results = described_class.new.call(user_id: user.id)
      expect(results).to contain_exactly(event1, event2)
    end

    it 'combines multiple filters' do
      results = described_class.new.call(
        location: 'Tokyo',
        user_id: user.id
      )
      expect(results).to contain_exactly(event1)
    end
  end
end

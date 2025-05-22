require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:user) { create(:user) }
  let(:event) { create(:event, user: user) }

  describe 'associations' do
    it 'belongs to user' do
      expect(event.user).to eq(user)
    end
  end

  describe 'validations' do
    it 'requires a title' do
      event.title = nil
      expect(event).to be_invalid
    end

    it 'requires a start_at' do
      event.start_at = nil
      expect(event).to be_invalid
    end

    it 'requires an end_at' do
      event.end_at = nil
      expect(event).to be_invalid
    end

    it 'is invalid when end_at is before start_at' do
      event.start_at = Time.current + 1.hour
      event.end_at = Time.current
      expect(event).to be_invalid
    end

    it 'is invalid when end_at equals start_at' do
      time = Time.current
      event.start_at = time
      event.end_at = time
      expect(event).to be_invalid
    end

    it 'is valid when end_at is after start_at' do
      event.start_at = Time.current
      event.end_at = Time.current + 1.hour
      expect(event).to be_valid
    end
  end

  describe 'scopes' do
    let!(:past_event) { create(:event, user: user, start_at: 2.days.ago, end_at: 1.day.ago) }
    let!(:current_event) { create(:event, user: user, start_at: 1.hour.ago, end_at: 1.hour.from_now) }
    let!(:future_event) { create(:event, user: user, start_at: 1.day.from_now, end_at: 2.days.from_now) }

    describe '.future' do
      it 'returns future events' do
        expect(Event.future).to include(future_event)
        expect(Event.future).not_to include(past_event, current_event)
      end
    end

    describe '.past' do
      it 'returns past events' do
        expect(Event.past).to include(past_event)
        expect(Event.past).not_to include(current_event, future_event)
      end
    end
  end
end

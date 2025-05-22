require 'rails_helper'

RSpec.describe 'Events', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:valid_attributes) do
    {
      title: 'Test Event',
      description: 'Test Description',
      start_at: 1.day.from_now,
      end_at: 2.days.from_now,
      location: 'Test Location'
    }
  end

  let(:invalid_attributes) do
    {
      title: '',
      description: 'Test Description',
      start_at: 2.days.from_now,
      end_at: 1.day.from_now,
      location: ''
    }
  end

  before do
    login(user, 'password')

    create(:permission, user: user, controller: 'events', action: 'index')
    create(:permission, user: user, controller: 'events', action: 'show')
    create(:permission, user: user, controller: 'events', action: 'new')
    create(:permission, user: user, controller: 'events', action: 'edit')
    create(:permission, user: user, controller: 'events', action: 'create')
    create(:permission, user: user, controller: 'events', action: 'update')
    create(:permission, user: user, controller: 'events', action: 'destroy')
  end

  describe 'GET /events' do
    let!(:event_tokyo) do
      create(:event,
             user: user,
             title: 'Tokyo Event',
             location: 'Tokyo',
             start_at: '2024-12-01 10:00:00',
             end_at: '2024-12-01 17:00:00')
    end

    let!(:event_osaka) do
      create(:event,
             user: other_user,
             title: 'Osaka Event',
             location: 'Osaka',
             start_at: '2024-11-01 10:00:00',
             end_at: '2024-11-01 17:00:00')
    end

    it 'returns a successful response' do
      get events_path
      expect(response).to be_successful
    end
  end

  describe 'GET /events/:id' do
    let(:event) { create(:event, user: user) }

    it 'returns a successful response' do
      get event_path(event)
      expect(response).to be_successful
    end
  end

  describe 'GET /events/new' do
    it 'returns a successful response' do
      get new_event_path
      expect(response).to be_successful
    end
  end

  describe 'GET /events/:id/edit' do
    context 'when accessing own event' do
      let(:event) { create(:event, user: user) }

      it 'returns a successful response' do
        get edit_event_path(event)
        expect(response).to be_successful
      end
    end

    context "when accessing other user's event" do
      let(:event) { create(:event, user: other_user) }

      it 'returns 404 not found' do
        get edit_event_path(event)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /events' do
    context 'with valid parameters' do
      it 'creates a new Event' do
        expect do
          post events_path, params: { event: valid_attributes }
        end.to change(Event, :count).by(1)
      end

      it 'redirects to events index' do
        post events_path, params: { event: valid_attributes }
        expect(response).to redirect_to(events_path)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Event' do
        expect do
          post events_path, params: { event: invalid_attributes }
        end.not_to change(Event, :count)
      end

      it 'returns unprocessable entity status' do
        post events_path, params: { event: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when user does not have permission' do
      before do
        user.permissions.where(controller: 'events', action: 'create').destroy_all
      end

      it 'returns forbidden status' do
        post events_path, params: { event: valid_attributes }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH /events/:id' do
    context 'when updating own event' do
      let(:event) { create(:event, user: user) }
      let(:new_attributes) { { title: 'Updated Title' } }

      context 'with valid parameters' do
        it 'updates the requested event' do
          patch event_path(event), params: { event: new_attributes }
          event.reload
          expect(event.title).to eq 'Updated Title'
        end

        it 'redirects to events index' do
          patch event_path(event), params: { event: new_attributes }
          expect(response).to redirect_to(events_path)
        end
      end

      context 'with invalid parameters' do
        it 'returns unprocessable entity status' do
          patch event_path(event), params: { event: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when updating other user's event" do
      let(:event) { create(:event, user: other_user) }

      it 'returns 404 not found' do
        patch event_path(event), params: { event: valid_attributes }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /events/:id' do
    context 'when deleting own event' do
      let!(:event) { create(:event, user: user) }

      it 'destroys the requested event' do
        expect do
          delete event_path(event)
        end.to change(Event, :count).by(-1)
      end

      it 'redirects to events index' do
        delete event_path(event)
        expect(response).to redirect_to(events_path)
      end
    end

    context "when deleting other user's event" do
      let!(:event) { create(:event, user: other_user) }

      it 'does not destroy the event' do
        expect do
          delete event_path(event)
        end.not_to change(Event, :count)
      end

      it 'returns 404 not found' do
        delete event_path(event)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

class EventsController < ApplicationController
  def index
    @events = Events::SearchQuery.new.call(params)
  end

  def show
    @event = current_user.events.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def edit
    @event = current_user.events.find(params[:id])
  end

  def create
    @event = current_user.events.build(event_params)

    if @event.save
      redirect_to events_path, notice: t('.messages.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @event = current_user.events.find(params[:id])
    if @event.update(event_params)
      redirect_to events_path, notice: t('.messages.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.events.find(params[:id]).destroy!
    redirect_to events_path, notice: t('.messages.destroyed')
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :start_at, :end_at, :location)
  end
end

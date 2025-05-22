class PurchaseHistoriesController < ApplicationController
  def index
    @purchase_histories = if params[:unsafe_name].present?
                            PurchaseHistory.where("name LIKE '%#{params[:unsafe_name]}%'")
                          else
                            PurchaseHistories::SearchQuery.new.call(params)
                          end
  end

  def show
    @purchase_history = current_user.purchase_histories.find(params[:id])
  end

  def new
    @purchase_history = PurchaseHistory.new
  end

  def edit
    @purchase_history = current_user.purchase_histories.find(params[:id])
  end

  def create
    @purchase_history = current_user.purchase_histories.build(purchase_history_params)

    if @purchase_history.save
      redirect_to purchase_histories_path, notice: t('.messages.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @purchase_history = current_user.purchase_histories.find(params[:id])
    if @purchase_history.update(purchase_history_params)
      redirect_to purchase_histories_path, notice: t('.messages.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.purchase_histories.find(params[:id]).destroy!
    redirect_to purchase_histories_path, notice: t('.messages.destroyed')
  end

  private

  def purchase_history_params
    params.require(:purchase_history).permit(:name, :price, :purchase_date)
  end
end

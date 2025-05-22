class TagsController < ApplicationController
  def index
    @tags = Tag.all
  end

  def show
    @tag = Tag.find(params[:id])
    @page = [params[:page].to_i, 1].max
    per_page = 10
    @posts = @tag.posts
                 .eager_load(:user)
                 .order(created_at: :desc)
                 .page(@page, per_page)
    @total_pages = @tag.posts.total_pages(per_page)
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      redirect_to @tag, notice: 'タグが正常に作成されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def update
    @tag = Tag.find(params[:id])
    if @tag.update(tag_params)
      redirect_to @tag, notice: 'タグが正常に更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Tag.find(params[:id]).destroy
    redirect_to tags_url, notice: 'タグが正常に削除されました。'
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end

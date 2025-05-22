class PostsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @page = [params[:page].to_i, 1].max
    per_page = 10
    @posts = @user.posts.page(@page, per_page)
    @total_pages = @user.posts.total_pages(per_page)
  end

  def show
    @user = User.find(params[:user_id])
    @post = @user.posts.find(params[:id])
  end

  def new
    @user = User.find(params[:user_id])
    @post = @user.posts.build
  end

  def edit
    @user = User.find(params[:user_id])
    @post = current_user.posts.find(params[:id])
  end

  def create
    @user = User.find(params[:user_id])
    @post = current_user.posts.build(post_params)

    if @post.save
      @post.update_tags(params[:post][:tag_ids])
      redirect_to user_post_path(@user, @post)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:user_id])
    @post = current_user.posts.find(params[:id])

    if @post.update(post_params)
      @post.update_tags(params[:post][:tag_ids])
      redirect_to user_post_path(@user, @post)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.posts.find(params[:id]).destroy
    redirect_to user_posts_path(params[:user_id])
  end

  private

  def post_params
    params.require(:post).permit(:title, :content)
  end
end

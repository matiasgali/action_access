class ArticlesController < ApplicationController
  let :admin, :all
  let :editor, [:edit, :update]
  let :cleaner, :destroy
  let :editor, :cleaner, :user, [:index, :show]

  # GET /articles
  def index
  end

  # GET /articles/1
  def show
  end

  # GET /articles/new
  def new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  def create
    redirect_to article_path(1), notice: 'Article was successfully created.'
  end

  # PATCH/PUT /articles/1
  def update
    redirect_to article_path(1), notice: 'Article was successfully updated.'
  end

  # DELETE /articles/1
  def destroy
    redirect_to articles_url, notice: 'Article was successfully destroyed.'
  end
end

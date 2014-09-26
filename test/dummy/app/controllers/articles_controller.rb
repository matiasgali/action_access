class ArticlesController < ApplicationController
  include ActionAccess::ControllerAdditions
  before_action :validate_access!

  let :admin, :all
  let :editor, [:index, :show, :edit, :update]
  let :user, [:index, :show]

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


  private

    def current_clearance_level
      session[:role] || :guest
    end
end

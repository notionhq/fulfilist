class UsersController < ApplicationController
  # load_and_authorize_resource
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    @lists = @user.lists.order("created_at DESC")
    # @items = @user.items.order("created_at DESC")
    respond_with @user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(params[:user])
    respond_with @user
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    respond_with @user
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_with @user
  end

end
class ListsController < ApplicationController
  def show
    @list = List.find(params[:id])
    @items = @list.items.available.order("created_at DESC")
    @claimed_items = @list.items.claimed.order("created_at DESC")
  end
  respond_to do |format|
    format.html { redirect_to user_list_url(@list.user, @list)}
    format.js
  end
  
  def new
    @list = List.new
  end
  
  def edit
    @list - List.find(params[:id])
  end
  
  def create
    @user = User.find(params[:user_id])
    @list = @user.lists.create!(params[:list])
    respond_to do |format|
      # format.html { redirect_to user_list_url(@list.user, @list)}
      format.js
    end
    
    
  end
  
  def update
    @list = current_user.lists.find(params[:id])
    @list.update_attributes(params[:list])
    respond_to do |format|
      format.html { redirect_to current_user }
      format.js
    end
  end
  
  def destroy
    @list = current_user.lists.find(params[:id])
    @list.destroy
    respond_to do |format|
      format.html{ redirect_to root_url }
      format.js
    end
  end
end
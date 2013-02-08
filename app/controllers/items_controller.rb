class ItemsController < ApplicationController
  # respond_to :html, :json, :js
  load_and_authorize_resource
  def show
    @item = Item.find(params[:id])
    respond_to do |format|
      format.html { redirect_to user_item_url(@item.user, @item)}
      format.js
    end
  end
  
  def new
    @item = Item.new
    
  end
  
  def edit
    @item = Item.find(params[:id])
  end
  
  def create
    @list = List.find(params[:list_id])
    @item = @list.items.create!(params[:item])
    respond_to do |format|
      format.html { redirect_to user_list_item_url(current_user, @list, @item)}
      format.js
    end
  end
  
  def update
    @list = List.find(params[:list_id])
    @item = @list.items.find(params[:id])
    @item.update_attributes(params[:item])
    respond_to do |format|
      format.html { redirect_to @list }
      format.js
    end
  end
  
  def destroy
    @list = List.find(params[:list_id])
    @item = @list.items.find(params[:id])
    @item.destroy
    respond_to do |format|
      format.html { redirect_to current_user }
      format.js
    end
  end
  
  def claim
    @item = Item.find(params[:item_id])
    @item.update_attributes(claimed: true, claimed_by: current_user.id)
    respond_to do |format|
      format.html { redirect_to user_item_url(@item.user, @item) }
      format.js
    end
  end
  
  def unclaim
    @item = Item.find(params[:item_id])
    @item.update_attributes(claimed: false, claimed_by: nil)
    respond_to do |format|
      format.html { redirect_to user_item_url(@item.user, @item) }
      format.js
    end
  end
  
  def update_with_info
    @list = List.find(params[:id])
    @item = @list.items.find(params[:item_id])
  end
end
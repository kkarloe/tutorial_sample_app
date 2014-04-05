class RelationshipsController < ApplicationController
  before_action :signed_in_user
  
  respond_to :html, :js
  
  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    respond_with @user
  end 
  
  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    # using respond_to (optionally can be replaced by respond_with as above)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js # calls destroy.js.erb
    end
  end
end
class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @micropost = current_user.microposts.build if signed_in?
      @feed_items = current_user.feed.paginate(page: params[:page])
      @user ||= current_user
      # Other, longer option:
      #if (@user == nil )
      #  @user = current_user
      #end

    end
  end

  def help
  end
  
  def about
  end
  
  def contact
  end
end

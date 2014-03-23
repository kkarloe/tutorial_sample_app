class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy]
  before_action :not_signed_in_user, only: [:new, :create]

  def show 
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  def index
    @test = "foo"
    #debugger
    @users = User.paginate(page: params[:page])
  end 

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the sample app"
      redirect_to @user
    else
      render 'new'  
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
       flash[:success] = "Profile updated"
       redirect_to @user
    else
      render 'edit'
    end

  end

  def destroy
    @user = User.find(params[:id])
    # Since destroy action can only be called by admin, current_user will be admin's id
    # Check whether user which is supposed to be deleted (@user) is an admin (current_user)
    logger.debug "Destroying user: #{@user.id}"
    if current_user?(@user)
      flash[:error] = "Cannot delete current admin"
    else
      @user.destroy
      flash[:success] = "User deleted."
    end
    redirect_to users_url
  end

  private
  
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # Before filters

    def not_signed_in_user
      if signed_in?
        redirect_to(root_url)
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end

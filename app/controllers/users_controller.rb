# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy correct_user following followers]
  before_action :logged_in_user, only: %i[index edit update destroy following followers]
  before_action :correct_user, only: %i[edit update]
  before_action :admin_users, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = 'Please check your email to activate your account.'
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit; end

  def update
    if @user.update_attributes(user_params)
      redirect_to @user, notice: 'Profile updated'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: 'User deleted'
  end

  def following
    @title = 'Following'
    @follow = @user.following
    @users = @follow.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = 'Followers'
    @follow = @user.followers
    @users = @follow.paginate(page: params[:page])
    render 'show_follow'
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end

  # before filter

  # confirmed the correct user
  def correct_user
    redirect_to(root_path) unless current_user?(@user)
  end

  def admin_users
    redirect_to(root_path) unless current_user.admin?
  end
end

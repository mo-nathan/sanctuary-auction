# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_admin!, except: %i[index show]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    params[:user][:code] = params[:user][:code].downcase.strip
    @user = User.new(user_params)

    if @user.save
      redirect_to @user
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    params[:user][:code] = params[:user][:code].downcase.strip
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to @user
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to root_path, status: :see_other
  end

  private

  def user_params
    params.require(:user).permit(:code, :name, :balance)
  end
end

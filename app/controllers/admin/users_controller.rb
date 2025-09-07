module Admin
  class UsersController < ApplicationController
    before_action :require_login
    before_action :require_admin!
    before_action :set_user, only: [:edit, :update, :destroy]

    def index
      @users = User.order(:email)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_users_path, notice: "User created"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      attrs = user_params
      attrs.delete(:password) if attrs[:password].blank?
      if @user.update(attrs)
        redirect_to admin_users_path, notice: "User updated"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "User deleted"
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :role, :department_id, :manager_id, :password)
    end
  end
end


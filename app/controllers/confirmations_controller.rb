# app/controllers/confirmations_controller.rb
class ConfirmationsController < ApplicationController
    before_action :redirect_if_authenticated, only: [:create, :new]

    def create
      @user = User.find_by(email: params[:user][:email].downcase)
  
      if @user.present? && @user.unconfirmed?
        @user.send_confirmation_email!
        redirect_to root_path, notice: "Check your email for confirmation instructions."
      elsif @user.present? && @user.confirmed?
        redirect_to new_confirmation_path, alert: " That email has already been confirmed."
      else
        redirect_to new_confirmation_path, alert: "We could not find a user with that email."
      end
    end
  
    def edit
      @user = User.find_signed(params[:confirmation_token], purpose: :confirm_email)
  
      if @user.present? && @user.unconfirmed_or_reconfirming?
        if @user.confirm!
        #   login @user
          redirect_to root_path, notice: "Your account has been confirmed. Please login in"
        else
          redirect_to new_confirmation_path, alert: "Something went wrong."
        end
      else
        redirect_to new_confirmation_path, alert: "Invalid token."
      end
    end
  
    def new
      @user = User.new
    end
end
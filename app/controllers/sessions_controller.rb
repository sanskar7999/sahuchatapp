class SessionsController < ApplicationController
    before_action :redirect_if_authenticated, only: [:create, :new]


    def new
    end

    def create
        @user = User.find_by(email: params[:email].downcase)
        if @user
            if @user.unconfirmed?
                redirect_to new_confirmation_path, alert: "Incorrect email or password."
            elsif @user.authenticate(params[:password])
                login @user
                redirect_to root_path, notice: "Signed in."
            else
                flash.now[:alert] = "Incorrect email or password."
                render :new, status: :unprocessable_entity
            end
        else
          flash.now[:alert] = "Incorrect email or password."
          render :new, status: :unprocessable_entity
        end
    end

    def destroy
        logout current_user
        redirect_to root_path, notice: "You have been logged out."
    end
end
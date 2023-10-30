class PasswordResetsController <ApplicationController
    before_action :set_uesr_by_token, only: [:edit, :update]

    def new
    end

    def create
        user = User.find_by(email: params[:email])
        if user.present?
            PasswordMailer.with(
                user: user,
                token: user.generate_token_for(:password_reset)
            ).password_reset.deliver_later
            redirect_to root_path, notice: "Check your email to reset your password."
        else
            redirect_to password_reset_path, alert: "We could not find a user with that email"
        end
    end

    def edit
    end

    def update
        if @user.update(password_params)
            redirect_to new_session_path, notice: "Your password has been reset successfully. Please login."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    private

    def password_params
        params.require(:user).permit(:password, :password_confirmation)
    end
    def set_uesr_by_token
        @user = User.find_by_token_for(:password_reset,params[:token])
        redirect_to new_password_reset_path notice: "Invalid token, please try again." unless @user.present?
    end
end
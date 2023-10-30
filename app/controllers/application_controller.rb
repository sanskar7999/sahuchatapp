class ApplicationController < ActionController::Base
    include Pagy::Backend
    before_action :turbo_frame_request_variant

    private

    def turbo_frame_request_variant
        request.variant = :turbo_frame if turbo_frame_request?
    end

    def authenticate_user!
        redirect_to root_path, alert: "You must be logged in to do that." unless user_signed_in?
    end

    def current_user
        Current.user = if session[:current_active_session_id].present?
        ActiveSession.find_by(id: session[:current_active_session_id])&.user
        end
    end
    helper_method :current_user

    def authenticate_user_from_session
        User.find_by(id: session[:user_id])
    end
    def redirect_if_authenticated
        redirect_to root_path, alert: "You are already logged in." if user_signed_in?
    end

    def user_signed_in?
        current_user.present?
    end
    helper_method :user_signed_in?

    def login(user)
        reset_session
        active_session = user.active_sessions.create!(user_agent: {
            "device type": request.device_type,
            "operating system": request.os,
            "os version": request.os_version,
            "Browser": request.browser,
            "Browser version": request.browser_version
            }, ip_address: request.ip)
        session[:current_active_session_id] = active_session.id
    end

    def logout(user)
        active_session = ActiveSession.find_by(id: session[:current_active_session_id])
        reset_session
        active_session.destroy! if active_session.present?
    end
end

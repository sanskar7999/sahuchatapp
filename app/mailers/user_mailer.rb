class UserMailer < ApplicationMailer

  def confirmation(user, confirmation_token)
    @user = user
    @confirmation_token = confirmation_token

    # mail to: @user.email, subject: "Confirmation Instructions"
    mail to: @user.confirmable_email, subject: "Confirmation Instructions"
  end
end

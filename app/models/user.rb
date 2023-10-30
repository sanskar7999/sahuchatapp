class User < ApplicationRecord
    has_secure_password
    has_many :active_sessions, dependent: :destroy
    validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, presence: true, uniqueness: true
    normalizes :email, with: ->(email) {email.strip.downcase}
    validates :name, uniqueness: true
    after_create_commit {broadcast_append_to "users"}
    after_update_commit { broadcast_update }
    has_many :messages
    enum status: %i[offline away online]

    #for photo
    has_one_attached :avatar

    scope :all_except, -> (user) {where.not(id: user)}
    CONFIRMATION_TOKEN_EXPIRATION = 10.minutes

    attr_accessor :current_password
    before_save :downcase_unconfirmed_email
    validates :unconfirmed_email, format: {with: URI::MailTo::EMAIL_REGEXP, allow_blank: true}

    generates_token_for :password_reset, expires_in: 15.minutes do
        password_salt&.last(10)
    end

    # generates_token_for :email_confirmation, expires_in: 24.hours do
    #     email
    # end

    def send_confirmation_email!
        confirmation_token = generate_confirmation_token
        UserMailer.confirmation(self, confirmation_token).deliver_now
    end

    def confirm!
        if unconfirmed_or_reconfirming?
          if unconfirmed_email.present?
            return false unless update(email: unconfirmed_email, unconfirmed_email: nil)
          end
          update_columns(confirmed_at: Time.current)
        else
          false
        end
    end

    def confirmable_email
        if unconfirmed_email.present?
          unconfirmed_email
        else
          email
        end
      end

    def confirmed?
        confirmed_at.present?
    end

    def unconfirmed?
        !confirmed?
    end
    def generate_confirmation_token
        signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, purpose: :confirm_email
    end

    def reconfirming?
        unconfirmed_email.present?
    end

    def unconfirmed_or_reconfirming?
        unconfirmed? || reconfirming?
    end

    def broadcast_update
      broadcast_replace_to 'user_status', partial: 'users/status', user: self
    end

    def status_to_css
      case status
      when 'online'
        'bg-success'
      when 'away'
        'bg-warning'
      when 'offline'
        'bg-dark'
      else
        'bg-dark'
      end
    end

    private
    def downcase_unconfirmed_email
        return if unconfirmed_email.nil?
        self.unconfirmed_email = unconfirmed_email.downcase
    end

end

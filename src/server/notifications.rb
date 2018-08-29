#
# Sends email with the cracked password.
# TODO: add notification field to creation form to
# include email and SMS
#
class Notifications
  def initialize
    @mail_send_count = 0
  end

  def mail(subject, body)
    options = { address:              'smtp.gmail.com',
                port:                 587,
                user_name:            ENV['GMAIL_EMAIL'],
                password:             ENV['GMAIL_APP_KEY'],
                authentication:       'plain',
                enable_starttls_auto: true }

    puts "Mail: #{options}, count [#{ @mail_send_count }]"

    Mail.defaults do
      delivery_method :smtp, options
    end

    # Deliver to SMS
    if @mail_send_count < 10
      Mail.deliver do
        to "#{ ENV['SMS_PHONE_NUM'] }@#{ ENV['SMS_CARRIER'] }"
        from 'noreply@hashpass.app'
        subject subject
        body body
      end
      @mail_send_count += 1
    end

    # Deliver to Email
    if false
      Mail.deliver do
        to "#{ ENV['EMAIL_TO'] }"
        from 'noreply@hashpass.app'
        subject subject
        body body
      end
      @mail_send_count += 1
    end
  end
end

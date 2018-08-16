#
# Sends email with the cracked password.
# TODO: add notification field to creation form to
# include email and SMS
#
class Notifications
  def mail(subject, body)
    options = { address:              'smtp.gmail.com',
                port:                 587,
                user_name:            ENV['GMAIL_EMAIL'],
                password:             ENV['GMAIL_APP_KEY'],
                authentication:       'plain',
                enable_starttls_auto: true }

    puts "Mail: #{options}, #{ENV}"

    Mail.defaults do
      delivery_method :smtp, options
    end

    # Deliver to SMS
    if true
      Mail.deliver do
        to "#{ ENV['SMS_PHONE_NUM'] }@#{ ENV['SMS_CARRIER'] }"
        from 'noreply@hashpass.app'
        subject subject
        body body
      end
    end

    # Deliver to Email
    if false
      Mail.deliver do
        to "#{ ENV['EMAIL_TO'] }"
        from 'noreply@hashpass.app'
        subject subject
        body body
      end
    end
  end
end

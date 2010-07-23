class MailMan < ActionMailer::Base
  
  layout 'mail'

  def new_user(user)
    subject    'New User on The Mashera Project'
    recipients ['jilliankozyra@gmail.com','ronanfarrow@gmail.com']
    from       'accounts@themasheraproject.org'
    sent_on    Time.now
    content_type 'text/html'
    body       :user => user
  end

  def user_approved(user)
    subject    'Welcome to the Mashera Project'
    recipients user.email
    bcc         ['jilliankozyra@gmail.com','ronanfarrow@gmail.com']
    from       'accounts@themasheraproject.org'
    sent_on    Time.now
    content_type 'text/html'
    body       :user => user
  end

end

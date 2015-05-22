class MassMailer < ActionMailer::Base
  include SendGrid
  include MarkdownHelper
  sendgrid_category :use_subject_lines

  FROM = '"Tea With Strangers" <sayhi@teawithstrangers.com>'


  def simple_mail(opts = {})
    from        = (opts[:from]        || FROM)
    to          = (opts[:to]          || FROM)
    body        = (opts[:body]        || "")
    subject     = (opts[:subject]     || "")
    recipients  = (opts[:recipients]  || all_recipients_for(opts[:city_id]))

    sendgrid_recipients recipients

    mail(to: to, from: from, subject: subject) do |f|
      f.html { render inline: markdown(body) }
      f.text { render text: body }
    end
  end

private
  def all_recipients_for(city_id)
    City.find(city_id).users.select(:email).map(&:email)
  end
end

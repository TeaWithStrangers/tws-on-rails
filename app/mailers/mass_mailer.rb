class MassMailer < ActionMailer::Base
  include SendGrid
  include MarkdownHelper
  sendgrid_category :use_subject_lines

  FROM = '"Tea With Strangers" <sayhi@teawithstrangers.com>'

  def simple_mail(opts = {})
    from  = (opts[:from] || FROM)
    to    = (opts[:to] || from)
    body  = (opts[:body] || "")
    sendgrid_recipients (opts[:recipients] || City.find(opts[:city_id]).users.select(:email).map(&:email))

    mail(to: to, from: from, subject: opts[:subject]) do |f|
      f.html { render inline: markdown(body) }
      f.text { render text: body }
    end
  end
end

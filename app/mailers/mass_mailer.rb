class MassMailer < ActionMailer::Base
  include SendGrid
  include MarkdownHelper
  sendgrid_category :use_subject_lines

  default from: '"Tea With Strangers" <sayhi@teawithstrangers.com>'


  def simple_mail(opts = {})
    from = (opts[:from] ||= '"Tea With Strangers" <sayhi@teawithstrangers.com>')
    to = (opts[:to] ||= from)
    sendgrid_recipients City.for_code!(opts[:city_id]).users.select(:email).map(&:email)

    mail(to: to, from: from, subject: opts[:subject]) do |f|
      f.html { render inline: markdown(opts[:body]) }
      f.text { render text: opts[:body] }
    end
  end
end

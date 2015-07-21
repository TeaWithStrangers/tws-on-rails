class EmailRemindersController < ApplicationController
  before_action :use_new_styles
  before_action :away_non_user
  before_action :authorize_host!

  def new
    if current_user.email_reminder.present?
      @email_reminder = current_user.email_reminder
      @form_url = update_email_reminders_path(@email_reminder)
    else
      @email_reminder = EmailReminder.new
      @form_url = email_reminders_path
    end
  end

  def create
    @email_reminder = EmailReminder.new(permitted_params)
    @email_reminder.remindable = current_user
    @email_reminder.t_minus_in_hours = 48 # probably make this customizable in the future
    if @email_reminder.save
      redirect_to profile_path, alert: 'Updated Custom Email Reminder!'
    else
      render 'new'
    end
  end

  def update
    @email_reminder = EmailReminder.find(params[:id])
    if @email_reminder.update_attributes(permitted_params)
      redirect_to profile_path
    else
      render 'new'
    end
  end

private
  def permitted_params
    params[:email_reminder].permit(:body)
  end
end

class AttendanceController < ApplicationController
  before_action :authenticate_user!
  before_action :user_authorized?, only: [:show, :update]
  before_action :host_authorized?, only: [:mark]
  before_action :set_attendance, except: [:mark]


  ############################################
  # Host-related Attendance Actions
  ############################################

  def mark
    @tea_time = TeaTime.find(params[:id])
    respond_to do |format|
      case params[:marking]
      when 'email'
        if params[:email_sent] == 'true'
          if @tea_time.advance_state!
            format.html { redirect_to host_tasks_path, notice: 'All done!' }
            format.json { render json: @tea_time }
          else
            format.html { redirect_to :back, alert: "That didn't work. Try again?" }
            format.json { render json: { errors: @tea_time.errors.full_messages } }
          end
        end
      when 'attendance'
        tea_time_params = params.fetch(:tea_time, {}).permit!
        if @tea_time.update!(tea_time_params) && @tea_time.advance_state!
          format.html { redirect_to host_tasks_path, notice: 'Thanks for taking
                        attendance! Now send an email to your attendees :)' }
          format.json { render json: @tea_time }
        else
          format.html {redirect_to :back, alert: 'Uh-oh. Something went wrong.
                       Care to try again?' }
          format.json { render json: { errors: @tea_time.errors.full_messages } }
        end
      when 'edit_attendance'
        @tea_time.update(followup_status: "pending")
        format.html { redirect_to :back, notice: "OK, care to mark again?" }
      end
    end
  end

  ############################################
  # User-related Attendance Actions
  ############################################
  def show
    render :flake, layout: !request.xhr?
  end

  # PUT /tea_times/1/attendance/2
  # TODO Looks like this ONLY "flakes" the attenance
  # It should probably look at params to see what the update
  # request is trying to do.
  def update
    respond_to do |format|
      if @attendance.flake!({reason: params[:attendance][:reason]})
        format.html { redirect_to profile_path, notice: 'Your spot is now open for someone else!' }
        format.json { render :show, status: :created, location: @tea_time }
      else
        format.html { redirect_to profile_path }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_attendance
    @tea_time = params[:id]
    @attendance = Attendance.find_by(tea_time: @tea_time, user: current_user)
  end

  def user_authorized?
    if !(can? :update, (@attendance || Attendance))
      redirect to :back, error: "I can't let you do that Dave"
    end
  end

  def host_authorized?
    if !(can? :manage, (@tea_time || TeaTime))
      redirect to :back, error: "I can't let you do that Dave"
    end
  end
end

class AttendanceController < ApplicationController
  before_action :authenticate_user!, :authorized?
  before_action :set_attendance, except: [:mark]


  ############################################
  # Host-related Attendance Actions
  ############################################

  def mark
    @tea_time = TeaTime.find(params[:id])
    if @tea_time.update(tea_time_params)
      @tea_time.followup_status = :marked_attendance; @tea_time.save
      redirect_to host_tasks_path, 
        notice: 'Thanks for taking attendance! Now send an email to your attendees :)'
    else
      redirect_to :back, error: 'Uh-oh. Something went wrong. Care to try again?' 
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
    @tea_time = params[:id]
    @attendance = Attendance.find_by(tea_time: @tea_time, user: current_user)

    respond_to do |format|
      if @attendance.flake!({reason: params[:reason]})
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

  def authorized?
    if !(can? :update, (@attendance || Attendance))
      redirect to :back, error: "I can't let you do that Dave"
    end
  end

  def tea_time_params
    permitted = [:start_time, :duration, :location, :city]
    params.require(:tea_time).permit!
  end
end

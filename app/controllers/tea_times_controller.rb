class TeaTimesController < ApplicationController
  helper TeaTimesHelper
  before_action :set_tea_time, except: [:index, :new, :create]
  before_action :authenticate_user!, :authorized?, only: [:new, :edit, :create, :update, :cancel, :destroy, :index]

  # GET /tea_times
  # GET /tea_times.json
  def index
    @tea_times = TeaTime.all
    respond_to do |format|
      format.html { render layout: !request.xhr? }
      format.json { render json: @tea_times }
    end
  end

  # GET /tea_times/1
  # GET /tea_times/1.json
  def show
    respond_to do |format|
      format.html { render layout: !request.xhr? }
      format.json { render json: @tea_time }
    end
  end

  # GET /tea_times/new
  def new
    @tea_time = TeaTime.new(city: current_user.home_city,
                            start_time: Time.now.beginning_of_hour + 1.day,
                            host: current_user)
  end

  # GET /tea_times/1/edit
  def edit
  end

  # POST /tea_times/1/attendance
  def create_attendance
    @user = current_user
    #FIXME: ALL THIS
    if @user.nil?
      user_data = GetOrCreateUser.call({nickname: tea_time_params[:nickname],
                                        email: tea_time_params[:email]},
                                        @tea_time.city)

      if user_data[:new_user?] && user_data[:user].valid?
        @user = user_data[:user]
        sign_in @user
      elsif !user_data[:new_user?] && user_data[:user].valid?
        return redirect_to new_user_session_path, alert: 'You already have an account. Log in! Then register for the tea time.'
      end
    end

    if @user.nil?
      return redirect_to tea_time_path(@tea_time), alert: "Sorry, something has gone wrong. Our fault. Try again!"
    end


    @attendance = Attendance.where(tea_time: @tea_time, user: @user).first_or_initialize
    @attendance.try_join

    if @attendance.save
      @attendance.queue_reminders
      message = @attendance.waiting_list? ?
        "You're on the wait list! Check your email for details." :
        "You're set for tea time! Check your email and add it to your calendar :)"
      respond_to do |format|
        format.html { return redirect_to profile_path, notice: message }
        format.json { @attendance }
      end
    else
      respond_to do |format|
        format.html { return redirect_to city_path(@tea_time.city),
                      alert: "Couldn't register for that, sorry :(" }
        format.json { @attendance }
      end
    end
  end

  # POST /tea_times
  # POST /tea_times.json
  def create
    @tea_time = TeaTime.new(tea_time_params)
    respond_to do |format|
      if @tea_time.save
        format.html { redirect_to profile_path, notice: 'Tea time was successfully created.' }
        format.json { render :show, status: :created, location: @tea_time }
      else
        format.html { render :new }
        format.json { render json: @tea_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tea_times/1
  # PATCH/PUT /tea_times/1.json
  def update
    respond_to do |format|
      if UpdateTeaTime.call(@tea_time, tea_time_params)
        format.html { redirect_to profile_path, notice: 'Tea time was successfully updated.' }
        format.json { render json: @tea_time, status: :ok, location: @tea_time }
      else
        format.html { render :edit }
        format.json { render json: @tea_time.errors, status: :unprocessable_entity }
      end
    end
  end

  def cancel
    respond_to do |format|
      if CancelTeaTime.call(@tea_time)
        format.html { redirect_to profile_path, notice: 'Tea time canceled' }
        format.json { render status: 204 }
      else
        format.html { redirect_to :back, error: "Something went wrong"}
        format.json { render status: 500 }
      end
    end
  end

  # DELETE /tea_times/1
  # DELETE /tea_times/1.json
  def destroy
    #Uncomment this if for some reason users should be able to delete TTs
    #@tea_time.destroy
    respond_to do |format|
      format.html { render text: "I can't let you do that, #{current_user.name}" }
      format.json { head 403 }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tea_time
      @tea_time = TeaTime.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tea_time_params
      permitted = [:start_time, :duration, :location, :city]
      #FIXME: Fuck Strong Params
      params.require(:tea_time).permit!
    end

    def authorized?
      if !(can? :manage, (@tea_time || TeaTime))
        redirect_to :back, error: 'Unauthorised!'
      end
    end
end

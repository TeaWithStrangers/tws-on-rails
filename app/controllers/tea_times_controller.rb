class TeaTimesController < ApplicationController
  helper TeaTimesHelper
  before_action :set_tea_time, only: [:show, :edit, :update, :destroy, :update_attendance, :create_attendance]
  before_action :prepare_tea_time_for_edit, only: [:create, :update]

  # GET /tea_times
  # GET /tea_times.json
  def index
    @tea_times = TeaTime.all
  end

  # GET /tea_times/1
  # GET /tea_times/1.json
  def show
  end

  # GET /tea_times/new
  def new
    @tea_time = City.first.tea_times.build
  end

  # GET /tea_times/1/edit
  def edit
  end

  # POST /tea_times/1/attendance
  def create_attendance
    @user = current_user
    #FIXME: ALL THIS
    if @user.nil?
      generated_password = Devise.friendly_token.first(8)
      @user = User.create(name: tea_time_params[:name], email: tea_time_params[:email], password: generated_password)
      sign_in(:user, @user)
      UserMailer.user_registration(@user, generated_password) if @user
    end
    status = :pending
    @attendance = Attendance.new(tea_time: @tea_time, user: @user)
    respond_to do |format|
      if @attendance.save
        UserMailer.tea_time_registration(@attendance)
        format.html { redirect_to profile_path, notice: 'Registered for Tea Time! See you soon :)' }
        format.json { @attendance }
      end
    end
  end

  # PUT /tea_times/1/attendance
  def update_attendance
    user, status = nil, nil
    if (current_user.host? || (can? :manage, :all))
      user = User.find(params[:user])
      status = params[:status]
    else
      user = current_user
      status = :flake
    end
    @attendance = Attendance.find_by(tea_time: @tea_time, user: user)
    @attendance.status = flake

    respond_to do |format|
      if @attendance.save
        UserMailer.tea_time_flake(@attendance) if status == :flake 
        format.html { redirect_to @tea_time, notice: 'Tea time was successfully created.' }
        format.json { render :show, status: :created, location: @tea_time }
      else
        format.html { redirect_to profile_path }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /tea_times
  # POST /tea_times.json
  def create
    respond_to do |format|
      if @tea_time.save
        format.html { redirect_to @tea_time, notice: 'Tea time was successfully created.' }
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
      if @tea_time.update(tea_time_params)
        format.html { redirect_to @tea_time, notice: 'Tea time was successfully updated.' }
        format.json { render :show, status: :ok, location: @tea_time }
      else
        format.html { render :edit }
        format.json { render json: @tea_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tea_times/1
  # DELETE /tea_times/1.json
  def destroy
    @tea_time.destroy
    respond_to do |format|
      format.html { redirect_to tea_times_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tea_time
      @tea_time = TeaTime.find(params[:id])
    end

    def prepare_tea_time_for_edit
      @tea_time ||= TeaTime.new(tea_time_params)
      @tea_time.city = City.find(params[:city])
      @tea_time.host = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tea_time_params
      permitted = [:start_time, :duration, :location, :city]
      #FIXME: Fuck Strong Params
      params.require(:tea_time).permit!
    end

    def parse_date(params)
      tt = params[:tea_time]
      date = tt[:start_date]
      time = tt[:start_time]
      d = "#{date} #{time}"
      Time.zone.strptime(d, "%m/%d/%y %H:%M")
    end
end

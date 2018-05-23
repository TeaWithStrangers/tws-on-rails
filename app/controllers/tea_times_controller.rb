class TeaTimesController < ApplicationController
  helper TeaTimesHelper
  before_action :set_tea_time, except: [:index, :list, :new, :create]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :authorized?, only: [:new, :edit, :create, :update, :cancel, :destroy, :list]
  before_action :use_new_styles, except: [:create, :update, :cancel, :destroy]

  # GET /tea_times
  # GET /tea_times.json
  def index
    @tea_times = TeaTime.this_month.order(start_time: :asc).includes(:city).all

    # Array of cities holding tea times this month
    # Extract all names of cities from tea times and deduplicate
    @cities = @tea_times.map { |tt| tt.city.name }.uniq

    # For each available city, create a hash entry and an empty list
    # of tea times
    @tea_times_by_city = Hash.new
    @cities.each { |city| @tea_times_by_city[city] = [] }

    # Iterate through tea times and segment into cities
    @tea_times.each do |tt|
      @tea_times_by_city[tt.city.name].push(tt)
    end

    respond_to do |format|
      format.html { render layout: !request.xhr? }
      format.json { render json: @tea_times }
    end
  end

  # GET /tea_times/list
  # GET /tea_times/list.json
  def list
    @tea_times = TeaTime.all
    respond_to do |format|
      format.html { render layout: !request.xhr? }
      format.json { render json: @tea_times }
    end
  end

  # GET /tea_times/1
  # GET /tea_times/1.json
  def show
    if user_signed_in?
      @new_attendance = @tea_time.attendances.new(user_id: current_user.id, provide_phone_number: true)
    end
    respond_to do |format|
      format.html { render layout: !request.xhr?, locals: { full_form: !request.xhr? } }
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

  # POST /tea_times
  def create
    @tea_time = TeaTime.new(tea_time_params)
    if @tea_time.save
      redirect_to profile_path, notice: 'Tea time was successfully created.'
    else
      redirect_to :back, notice: "Invalid submission: #{@tea_time.errors.full_messages.join(', ')}"
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

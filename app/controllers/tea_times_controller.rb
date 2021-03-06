class TeaTimesController < ApplicationController
  helper TeaTimesHelper
  before_action :set_tea_time, except: [:index, :list, :new, :create]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :authorized?, only: [:new, :edit, :create, :update, :cancel, :destroy, :list]
  before_action :use_new_styles, except: [:create, :update, :cancel, :destroy]

  # GET /tea_times
  # GET /tea_times.json
  def index
    @tea_times_this_month = TeaTime.this_month.order(start_time: :asc).includes(:city).all
    @this_month = transform_tea_times(filter_tea_times(@tea_times_this_month))

    @next_month = nil
    @days_until_next_month = (Date.today.end_of_month - 10.days - Date.today + 1).to_i

    # Determine if we should show next month's tea times
    if Date.today > Date.today.end_of_month - 10.days
      @tea_times_next_month = TeaTime.next_month.order(start_time: :asc).includes(:city).all
      @next_month = transform_tea_times(filter_tea_times(@tea_times_next_month, true))
    end

    respond_to do |format|
      format.html { render layout: !request.xhr? }
      format.json { render json: @tea_times_this_month }
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

  # Transform a list of tea times into a Hash containing:
  #
  # - tea_times_by_city: Hash with key city_name, value TeaTime, sort by count
  # - cities: Array of Strings of city names
  # - city_to_city_code: Hash that maps city_name to city_code
  def transform_tea_times(tea_times)
    # For each available city, create a hash entry and an empty list
    # of tea times
    tea_times_by_city = Hash.new

    # Iterate through tea times and segment into cities
    tea_times.each do |tt|
      if tea_times_by_city[tt.city.name] == nil
        tea_times_by_city[tt.city.name] = []
      end
      tea_times_by_city[tt.city.name].push(tt)
    end

    # Sort by the number of tea times in each city, most to least
    tea_times_by_city = Hash[tea_times_by_city.sort_by {|city, tt_array| tt_array.length}.reverse]

    # Array of cities holding tea times this month
    # Extract all names of cities from tea times and deduplicate
    cities = tea_times_by_city.keys.uniq

    # Extract a mapping from city name to city code
    # Fall back on the full city name if there's no city code
    city_to_city_code = Hash.new
    tea_times_by_city.each do |city_name, tt_list|
      tt_list.each do |tt|
        if tt.city.city_code.blank?
          city_to_city_code[tt.city.name] = tt.city.name
        else
          city_to_city_code[tt.city.name] = tt.city.city_code
        end
      end
    end

    {
      tea_times_by_city: tea_times_by_city,
      cities: cities,
      city_to_city_code: city_to_city_code
    }
  end

  # Filter tea times by ensuring that the tea time is within the start/end time
  # window relative to its own time zone.
  #
  # Since tea times are displayed in the time zone local to the city they are
  # in, but stored in the database as UTC, constraining a query based on UTC
  # may lead to past tea times being included or extra tea times from the future
  # being included.
  #
  # For example, making a query for tea times after the current day in UTC
  # also shows tea times that happened the previous day in time zones that are
  # behind UTC (e.g. it will show tea times that happened during the previous
  # day in the US, since 00:00 UTC translates to the previous day in US time
  # zones.)
  #
  # To solve this, we:
  # - Adjust the tea time query scopes to account for all time zones, which
  #   means accounting for UTC-12 to UTC+14. This will include extra tea times.
  # - After retrieving from the database, filter each tea time by making sure
  #   that each tea time happens within the time range (current month or next
  #   month, depending on what is being displayed) in the local time zone.
  def filter_tea_times(tea_times, next_month = false)
    # Return an array of tea times filtered based on this select block.
    tea_times.select { |tt|
      if tt.city.nil? or tt.city.timezone.blank?
        # If no city or city timezone information, include by default
        true
      else
        # 1. Check if tea time start_time is at least:
        # - Current month: The beginning of the day in the local time zone
        # - Next month: The first day of the month in the local time zone

        beginning_in_tz = Time.now.in_time_zone(tt.city.timezone)
                              .at_beginning_of_day

        if next_month
          beginning_in_tz = Time.now.in_time_zone(tt.city.timezone)
                                .at_beginning_of_month
                                .next_month
        end

        # 2. Check if tea time start_time is at most:
        # - Current month: The end of the current month in the local time zone
        # - Next month: The end of the next month in the local time zone

        end_of_month_in_tz = Time.now.in_time_zone(tt.city.timezone)
                                 .at_end_of_month

        if next_month
          end_of_month_in_tz = Time.now.in_time_zone(tt.city.timezone)
                                   .at_beginning_of_month
                                   .next_month
                                   .at_end_of_month
        end

        tt.start_time >= beginning_in_tz and tt.start_time <= end_of_month_in_tz
      end
    }
  end
end

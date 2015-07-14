class CitiesController < ApplicationController
  before_action :set_city, except: [:index, :new, :index]
  before_action :authenticate_user!, :authorized?, only: [:new, :create, :edit, :update, :destroy]
  before_action :away_ye_waitlisted, except: [:index, :show, :set_city]
  before_action :use_new_styles, except: [:set_city, :new, :edit, :create, :update, :destroy]

  # GET /cities
  def index
    @active_cities = City.fully_brewed.order(users_count: :desc)
    @upcoming_cities = City.where.not(brew_status: City.brew_statuses[:fully_brewed]).order(users_count: :desc)
  end

  def set_home_city
    current_user.update_attributes(home_city: @city)
    redirect_to city_path(@city)
  end

  # GET /:id (city code)
  def show
  end

  # GET /cities/new
  def new
    @city = City.new
  end

  # GET /cities/1/edit
  def edit
  end

  # POST /cities
  # POST /cities.json
  def create
    @city = City.new(city_params)
    respond_to do |format|
      if @city.save
        format.html { redirect_to @city, notice: 'City was successfully created.' }
        format.json { render :show, status: :created, location: @city }
      else
        format.html { render :edit }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cities/1
  # PATCH/PUT /cities/1.json
  def update
    if params[:approval_action]
      approver = CityApprover.new(@city)
      case params[:approval_action]
      when "merge"
        approver.merge!(params[:merge_city_id])
      when "approve"
        approver.approve!
      when "reject"
        approver.reject!
      end
    end

    respond_to do |format|
      if @city.update(city_params)
        format.html { redirect_to @city, notice: 'City was successfully updated.' }
        format.json { render :show, status: :ok, location: @city }
      else
        format.html { render :edit }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cities/1
  # DELETE /cities/1.json
  def destroy
    @city.destroy
    respond_to do |format|
      format.html { redirect_to cities_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_city
      @city = City.for_code(params[:id]) || City.find(params[:id])
    end

    def authorized?
      authorize! :manage, City
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def city_params
      params.require(:city).permit!
    end
end

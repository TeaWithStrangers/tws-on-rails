class CitiesController < ApplicationController
  before_action :set_city, only: [:show, :edit, :update, :destroy, :schedule]
  before_action :authenticate_user!, :authorized?, only: [:new, :create, :edit, :update, :destroy]
  before_filter :away_ye_waitlisted

  # GET /cities
  # GET /cities.json
  def index
    if can? :manage, City
      @cities = City.all
      respond_to do |format|
        format.html { render layout: !request.xhr? }
        format.json { render json: @cities }
      end
    else
      redirect_to root_path+"#cities"
    end
  end

  # GET /cities/:city_code
  # GET /cities/:city_code.json
  def show
    respond_to do |format|
      format.html { render layout: !request.xhr? }
      format.json { render json: @city }
    end
  end

  def schedule
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

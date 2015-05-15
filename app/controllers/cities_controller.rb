class CitiesController < ApplicationController
  before_action :set_city, except: [:index, :new, :forbes_index, :forbes_new, :forbes_create]
  before_action :authenticate_user!, :authorized?, only: [:new, :create, :edit, :update, :destroy]
  before_action :away_ye_waitlisted, except: [:forbes_index, :forbes_show, :forbes_new, :forbes_suggest, :forbes_create, :forbes_set_city]

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

  def forbes_index
    use_new_styles
  end

  def forbes_show
    if current_user
      use_new_styles
    else
      flash[:notice] = 'You should sign up first!'
      redirect_to sign_up_path
    end
  end

  def forbes_new
    use_new_styles
    @city = City.new
  end

  def forbes_create
    #NOTE: Seems unnecessary but required for the error case
    use_new_styles

    @city = NewSuggestedCity.call(city_params, current_user)

    respond_to do |format|
      if @city.persisted?
        format.html { redirect_to forbes_city_path(@city), notice: 'Thanks!' }
      else
        format.html { render :forbes_new, alert: "Something went wrong, sorry" }
      end
    end
  end

  def forbes_set_city
    current_user.update(home_city: @city)
    redirect_to forbes_city_path(@city)
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

class TeaTimesController < ApplicationController
  before_action :set_tea_time, only: [:show, :edit, :update, :destroy]

  # GET /tea_times
  # GET /tea_times.json
  def index
    @tea_times = City.find_by!(:city_code => params[:city_id].upcase).tea_times
    respond_to do |format|
      format.json { render json: @tea_times }
    end
  end

  # GET /tea_times/1
  # GET /tea_times/1.json
  def show
    respond_to do |format|
      format.json { render json: @tea_time }
    end
  end

  # GET /tea_times/new
  def new
    @tea_time = TeaTime.new
  end

  # GET /tea_times/1/edit
  def edit
  end

  # POST /tea_times
  # POST /tea_times.json
  def create
    @tea_time = TeaTime.new(tea_time_params)

    respond_to do |format|
      if @tea_time.save
        format.json { render :show, status: :created, location: @tea_time }
      else
        format.json { render json: @tea_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tea_times/1
  # PATCH/PUT /tea_times/1.json
  def update
    respond_to do |format|
      if @tea_time.update(tea_time_params)
        format.json { render :show, status: :ok, location: @tea_time }
      else
        format.json { render json: @tea_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tea_times/1
  # DELETE /tea_times/1.json
  def destroy
    @tea_time.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tea_time
      @tea_time = TeaTime.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tea_time_params
      params[:tea_time]
    end
end

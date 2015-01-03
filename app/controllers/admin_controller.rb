class AdminController < ApplicationController
  before_action :authenticate_user!, :authorized?

  def find
  end

  def overview
    @tea_times = TeaTime.all.order('start_time DESC')
  end

  def host_overview
    @hosts = User.hosts.includes(:tea_times)
  end

  def users
  end

  @@graph_color_map = [
    {
      'strokeColor' => 'rgb(116, 139, 167)',
      'color' => 'rgb(116, 139, 167)',
      'fillColor' => 'rgba(116, 139, 167, 0.4)',
      'highlight' => 'rgba(116, 139, 167, 0.4)'
    },
    {
      'strokeColor' => 'rgb(75, 104, 139)',
      'color' => 'rgb(75, 104, 139)',
      'fillColor' => 'rgba(75, 104, 139, 0.4)',
      'highlight' => 'rgba(75, 104, 139, 0.4)'
    },
    {
      'strokeColor' => 'rgb(20, 49, 83)',
      'color' => 'rgb(20, 49, 83)',
      'fillColor' => 'rgba(20, 49, 83, 0.4)',
      'highlight' => 'rgba(20, 49, 83, 0.4)'
    },
    {
      'strokeColor' => 'rgb(5, 28, 56)',
      'color' => 'rgb(5, 28, 56)',
      'fillColor' => 'rgba(5, 28, 56, 0.4)',
      'highlight' => 'rgba(5, 28, 56, 0.4)'
    },
    {
      'strokeColor' => 'rgb(43, 74, 111)',
      'color' => 'rgb(43, 74, 111)',
      'fillColor' => 'rgba(43, 74, 111, 0.4)',
      'highlight' => 'rgba(43, 74, 111, 0.4)'
    }
  ]

  def statistics
  end

  def stats_api_hosts_by_city
      @data = []

      @cities = City.all.order('id').all
      
      @cities.map {|city|
        @data << {
          'label' => city.name,
          'value' => city.hosts.count
        }
      }

      @data.each_with_index { |item, index|
        item.merge! @@graph_color_map[index]
        @data[index] = item
      }

      apiResponse = {'response' => @data}

      if not Rails.env.production?
        apiResponse = JSON.pretty_generate(apiResponse)
      end

      render :json => apiResponse
  end

  def stats_api_teatimes_by_city
      @data = []

      @cities = City.all.order('id').all
      
      @cities.map {|city|
        @data << {
          'label' => city.name,
          'value' => city.tea_times.count
        }
      }

      @data.each_with_index { |item, index|
        item.merge! @@graph_color_map[index]
        @data[index] = item
      }

      apiResponse = {'response' => @data}

      if not Rails.env.production?
        apiResponse = JSON.pretty_generate(apiResponse)
      end

      render :json => apiResponse
  end

  def write_mail
    @mail = MassMail.new
  end
  
  #TODO Test and reject invalid inputs
  def send_mail
    @mail = MassMail.new(params[:admin_controller_mass_mail])
    if @mail.valid?
      MassMailer.delay.simple_mail(@mail.to_hash)
      flash[:notice] = 'Message sent! Woohoo'
      redirect_to action: :write_mail
    else
      flash[:alert] = 'Woopsy. You forgot something. Come again?'
      render :write_mail
    end
  end


  def ghost
    user = User.find_by(email: params[:email])
    if user
      sign_in(:user, user)
      redirect_to profile_path
    else
      redirect_to :back
    end
  end

  private
    def authorized?
      unless current_user.admin?
        redirect_to root_url, :notify => "You're not allowed in here!"
      end
    end

    class MassMail
      include ActiveModel::Model

      ATTRIBUTES = %i(from to subject city_id body)
      attr_accessor *ATTRIBUTES
      validates_presence_of :subject, :body, :city_id 

      def initialize(attributes = {})
        attributes.each do |name, value|
          if !value.blank?
            send("#{name}=", value)
          end
        end
      end

      def to_hash
        ATTRIBUTES.inject({}) do |hsh, k|
          hsh[k] = send(k.to_s)
          hsh
        end
      end
      def persisted?
        false
      end

    end
end

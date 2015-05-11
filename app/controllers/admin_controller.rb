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

  def cities_overview
    @cities = City.order(:created_at).reverse_order
  end

  def users
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

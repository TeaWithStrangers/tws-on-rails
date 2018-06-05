class AdminController < ApplicationController
  before_action :authenticate_user!, :authorized?
  before_action :use_new_styles, except: [:host_overview, :users, :send_mail, :ghost]

  def find
  end

  def overview
    @tea_times = TeaTime.all.order('start_time DESC')
  end

  def tea_times_overview
    @tea_times = TeaTime.order('start_time DESC').paginate(page: params[:page], per_page: 50)
  end

  def host_overview
    @hosts = User.hosts.includes(:tea_times)
  end

  def cities_overview
    @cities = City.order(:created_at).includes(:suggested_by_user).reverse_order
  end

  def users
  end

  def write_mail
    @mail = MassMail.new
  end

  #TODO Test and reject invalid inputs
  def send_mail
    # THE FORM DOESN'T PASS IN A TO FIELD, so that is always set to default
    opts = {
      subject:  params[:mass_mail][:subject],
      body:     params[:mass_mail][:body],
      city_id:  params[:mass_mail][:city_id],
    }

    # We assign this only if it exists
    # because we don't want to set it explicitly to nil
    opts[:from] = params[:mass_mail][:from] if params[:mass_mail][:from].present?

    # We set the to the same as from address from the form.
    # The actual recipients are currently assigned based on
    # users City from the city_id from the form.
    opts[:to] = params[:mass_mail][:from] if params[:mass_mail][:from].present?

    if opts[:city_id].to_i.zero?
      opts[:recipients] = User.all.select(:email).map(&:email) 
    else
      city = City.find(opts[:city_id])
      opts[:recipients] = case params[:mass_mail][:recipients]
      when "all"
        city.users.select(:email).map(&:email)
      when "waitlisted"
        city.users.where(waitlisted: true).select(:email).map(&:email)
      else
        city.users.where(waitlisted: false).select(:email).map(&:email)
      end
    end

    # check that all params exist
    if opts[:subject].nil? || opts[:body].nil? || opts[:city_id].nil?
      flash[:alert] = 'Woopsy. You forgot something. Come again?'
      render :write_mail
    else

      MassMailer.delay.simple_mail(opts)
      flash[:notice] = 'Message sent! Woohoo'
      redirect_to action: :write_mail
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

  def segment
    @segments = SendGridList.get_segments
  end

  def segment_create
    name = params[:segment][:name]
    segments = params[:segment][:segments]
    sample = params[:segment][:sample]

    if sample.blank?
      sample = nil
    else
      sample = sample.delete(',').to_i
    end

    if name.blank?
      name = 'List'
    end

    SendGridList.delay.create_list_from_segments(name, segments, sample)

    # if @list_id === false
    #   flash[:error] = 'Error creating list. Did you already use that list name?'
    #   redirect_to segment_path
    # else
    #   flash[:success] = 'Successfully created list. Note: the SendGrid UI may not immediately display all contacts in the list.'
    #   @list_url = 'https://sendgrid.com/marketing_campaigns/ui/lists/%d' % [@list_id]
    # end
    flash[:success] = 'Successfully queued list for creation.'
  end

  def segment_count
    segments = params[:segments]
    render text: SendGridList.get_recipients(segments).length
  end

  private
    def authorized?
      unless current_user.admin?
        redirect_to root_url, :notify => "You're not allowed in here!"
      end
    end
end

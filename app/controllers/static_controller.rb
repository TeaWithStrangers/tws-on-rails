class StaticController < ApplicationController
  before_filter :away_ye_waitlisted, except: [:index, :jfdi_signup, :hosting, :about]
  before_action :use_new_styles

  def index
    @press = {
      'fast-company' => 'http://fastcompany.com',
      'forbes' => 'http://forbes.com',
      'huffington-post' => 'http://www.huffingtonpost.com/dr-shelley-prevost/creating-a-better-world-o_b_6061626.html',
      'tedxteen' => 'http://www.tedxteen.com/speakers-performers/tedxteen-2014-london/237-ankit-shah'
    }
    @cities = City.visible
    @cities_by_host  = Hash.new([]).merge(
      @cities.group_by { |x|
        if (x.fully_brewed? || x.warming_up?)
          :hosts
        else
          :no_hosts
        end
      })
  end

  def hosting
  end

  def about
  end

  def jfdi_signup
    # Querystring params (all optional):
    # - redirect_to_tt: integer - Set the tea time to redirect to after signup
    # - city_id: integer - Set the default selected city in home city dropdown
    # - remind_next_month: (any) - Pass a querystring param to the registration
    #   action handler to display the banner that we'll remind them next month

    @full_form = !request.xhr?
    return redirect_to profile_path if current_user

    # If the redirect_to_tt parameter exists, store the URL
    # to redirect to after signup
    # See https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
    if params[:redirect_to_tt] && TeaTime.find(params[:redirect_to_tt])
      store_location_for(:user, '/tea_times/' + params[:redirect_to_tt])
    end

    # Set parameters for after registration completes
    # We want to show a banner after registration that we'll remind them next month
    # This passes through the querystring param ?remind_next_month to the registration handler
    @form_action_params = {}
    if params.has_key?(:remind_next_month)
      @form_action_params['remind_next_month'] = ''
    end

    # Generate cities list, prepend a placeholder element
    # @active_cities = City.fully_brewed.order(users_count: :desc)
    # @upcoming_cities = City.where(
    #     brew_status: [City.brew_statuses[:cold_water], City.brew_statuses[:warming_up]]
    # ).order(users_count: :desc)
    # @cities = @active_cities + @upcoming_cities
    @cities = City.where(
        brew_status: [City.brew_statuses[:fully_brewed], City.brew_statuses[:cold_water], City.brew_statuses[:warming_up]]
    ).order(name: :asc)
    @cities_set = @cities.collect { |city| [city.name, city.id] }

    # Add the placeholder and Other option
    @cities_set_with_blank = @cities_set.prepend(['Home city', nil]).append(['Other', 'other'])

    # Set selected city in dropdown
    @selected_city = ''
    if params[:city_id] && City.find(params[:city_id])
      # If a default city is selected, set the selected city in the dropdown
      @selected_city = City.find(params[:city_id]).id
    end

    if @full_form
      render 'registrations/sign_up'
    else
      render 'shared/_new_sign_up', layout: @full_form
    end
  end
end

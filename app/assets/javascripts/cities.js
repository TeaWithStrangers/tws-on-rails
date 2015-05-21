var onCitiesIndexLoad = function() {
  if (window.location.pathname.indexOf('/cities') >= 0) {

    var listOfActiveCities = [];
    var listOfUpcomingCities = [];

    /*
    ** Returns city link component (string)
    ** @city Object // City Object with attributes city_code (string) & name (string)
    */
    var cityLink = function(city) {
      return '<a class="city-name" href="/' + city.city_code + '">' + city.name + "</a>"
    }

    /*
    ** Returns city link with background filter component (string)
    ** @city Object // City Object with attributes city_code (string) & name (string)
    */
    var cityLinkBg = function(city) {
      return '<a class="background-filter" href="/' + city.city_code + '">' + city.name + "</a>"
    }

    /*
    ** Adds 'loading' class to cities-partial element
    */
    function setLoading() {
      $('.cities-partial').addClass('loading');
    }

    /*
    ** Removes 'loading' class to cities-partial element
    */
    function unsetLoading() {
      $('.cities-partial').removeClass('loading');
    }

    /*
    ** Loads City Data received from API (TODO refactor method)
    ** @data Object
    */
    function loadCitiesData(data) {
      var cities = _(data.cities).chain()
        .sortBy(function(c) {
          return c.info.user_count;
        }).reverse()
      .sortBy(function(c) {
        switch(c.brew_status) {
          case 'fully_brewed':
            return 100;
          case 'warming_up':
            return 10;
          case 'hidden':
            return -1000;
        }
        return 1;
      })
      .value()

        $.each(cities, function(index, city){
            var cityDiv = '<div class="city"><div class="city-image" style="background: url('+city.header_bg_small+') no-repeat 50% 50%; background-size: cover;"><h2 class=" city-name">' + cityLinkBg(city) + cityLink(city) + '</h2></div></div>';
          if(city.brew_status === "fully_brewed"){
            listOfActiveCities.push(cityDiv);
          }
          else if(!(city.brew_status === "unapproved") && !(city.brew_status === "hidden")) {
            listOfUpcomingCities.push(cityDiv);

          }
        });
      $('.current-cities-container').html(listOfActiveCities.join(' '));
      $('.upcoming-cities-container').html(listOfUpcomingCities.join(' '));

      unsetLoading();
    }
    /*
    ** Error from /cities API
    ** @error Object
    */
    function citiesDataError(error) {
      throw new Error('Cities could not be loaded: %s', error);
    }

    setLoading();
    $.getJSON('/api/v1/cities', loadCitiesData, citiesDataError);
  }
};

var onCitiesShow = function() {
  var leading_button = $('a[data-user-interest="leading"]');
  var hosting_button = $('a[data-user-interest="hosting"]');

  $.get('/api/v1/users/self/interests', function(user_info) {
    if(!user_info) { return; }

    if(user_info.leading) {
      leading_button.addClass('applied');
    }

    if(user_info.hosting) {
      hosting_button.addClass('applied');
    }

  });

  [leading_button, hosting_button].forEach(function(btn) {
    btn.on('click', function(evt) {
      var type = evt.currentTarget.dataset.userInterest;
      var data = {'tws_interests': {}};
      data['tws_interests'][type] = true
        $.ajax({
          url: '/api/v1/users/self/interests',
          type: 'PATCH',
          data: data,
          success: function(d) {
            $(evt.currentTarget).addClass('applied', 'disabled')
          }
        });
    });
  });
}


var fns = [onCitiesIndexLoad, onCitiesShow];

fns.forEach(function(e,i) {
  $(document).ready(e)
  $(document).on('page:load', e)
});

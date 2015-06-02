'use strict';

function setLoading() {
  $('.cities-partial').addClass('loading');
}

function unsetLoading() {
  $('.cities-partial').removeClass('loading');
}

var onCitiesIndexLoad = function() {
  if (window.location.pathname === '/cities/' ||
    window.location.pathname === '/cities') {

    var listOfActiveCities = [];
    var listOfUpcomingCities = [];

    var cityLink = function(city) {
      /*jshint camelcase: false */
      return '<a class="city-name" href="/' + city.city_code + '">' + city.name + "</a>";
    }

    var cityLinkBg = function(city) {
      /*jshint camelcase: false */
      return '<a class="background-filter" href="/' + city.city_code + '">' + city.name + "</a>";
    }

    setLoading();
    $.get('/api/v1/cities', function(data) {

      var cities = _(data.cities).chain()
        .sortBy(function(c) {
              /*jshint camelcase: false */
          return c.info.user_count;
        }).reverse()
        .sortBy(function(c) {
          /*jshint camelcase: false */
          switch (c.brew_status) {
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

      $.each(cities, function(index, city) {
        /*jshint camelcase: false */
        var cityDiv = '<div class="city"><div class="city-image" style="background: url(' + city.header_bg + ') no-repeat 50% 50%; background-size: cover;"><h2 class=" city-name">' + cityLinkBg(city) + cityLink(city) + '</h2></div></div>';
        if (city.brew_status === "fully_brewed") {
          listOfActiveCities.push(cityDiv);
          /*jshint camelcase: false */
        } else if (!(city.brew_status === "unapproved") && !(city.brew_status === "hidden")) {
          listOfUpcomingCities.push(cityDiv);

        }
      });
      $('.current-cities-container').html(listOfActiveCities.join(' '));
      $('.upcoming-cities-container').html(listOfUpcomingCities.join(' '));

      unsetLoading();
    });
  }
};

var onCitiesShow = function() {
  /*jshint camelcase: false */
  var leading_button = $('a[data-user-interest="leading"]');
  /*jshint camelcase: false */
  var hosting_button = $('a[data-user-interest="hosting"]');

  $.get('/api/v1/users/self/interests', function(user_info) {
    if (!user_info) { return; }
    if (user_info.leading) {
      leading_button.addClass('applied');
    }

    if (user_info.hosting) {
      hosting_button.addClass('applied');
    }

  });

  [leading_button, hosting_button].forEach(function(btn) {
    btn.on('click', function(evt) {
      // var type = evt.currentTarget.dataset.userInterest;
      var data = {
        'tws_interests': {}
      };
      /*jshint camelcase: false */
      data.tws_interests.type = true;
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

fns.forEach(function(e) {
  $(document).ready(e);
  $(document).on('page:load', e);
});

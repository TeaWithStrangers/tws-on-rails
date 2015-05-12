var onCitiesIndexLoad = function() {

  var listOfActiveCities = [];
  var listOfUpcomingCities = [];

  var cityLink = function(city) {
    return '<a href="/cities/' + city.city_code + '">' + city.name + "</a>"
  }

  $.get('/api/v1/cities', function(data){
    var cities = _(data.cities).chain()
    .sortBy(function(c) {
      return c.info.user_count;
    }).reverse()
    .sortBy(function(c) {
      switch(c.brew_status) {
        case 'fully_brewed':
          console.log(100)
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

      console.log(city.name, city.info.user_count, city.brew_status)
      var cityDiv = '<div class="city"><img class="city-image" src="'+city.header_bg+'"/><h3 class="city-name">' + cityLink(city) + '</h3></div>';
      if(city.brew_status === "fully_brewed"){
        listOfActiveCities.push(cityDiv);
      }
      else if(!(city.brew_status === "unapproved") && !(city.brew_status === "hidden")) {
        listOfUpcomingCities.push(cityDiv);

      }
    });
    $('.current-cities-container').html(listOfActiveCities.join(' '));
    $('.upcoming-cities-container').html(listOfUpcomingCities.join(' '));
  });
};


$(document).ready(onCitiesIndexLoad)
$(document).on('page:load', onCitiesIndexLoad)

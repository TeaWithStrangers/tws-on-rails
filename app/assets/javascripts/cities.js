var danCallThisFunction = function() {

  var listOfActiveCities = [];
  var listOfUpcomingCities = [];

  $.get('http://localhost:3000/api/v1/cities', function(data){
    $.each(data.cities, function(index, city){
      console.log(city);

      var cityDiv = '<div class="city"><img class="city-image" src="'+city.header_bg+'"/><div class="city-name">'+city.name+'</div></div>';
      if(city.brew_status === "fully_brewed"){
        listOfActiveCities.push(cityDiv);
      }
      else{
        listOfUpcomingCities.push(cityDiv);
      }
    });
    $('.current-cities-container').html(listOfActiveCities.join(' '));
    $('.upcoming-cities-container').html(listOfUpcomingCities.join(' '));
  });

};


$(document).ready(danCallThisFunction)
$(document).on('page:load', danCallThisFunction)

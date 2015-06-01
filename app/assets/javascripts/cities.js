(function() {
	'use strict';

	var onCitiesIndexLoad = function() {
		if (window.location.pathname.indexOf('/cities') >= 0) {

			var listOfActiveCities = [];
			var listOfUpcomingCities = [];

			/**
			 * Returns a link to the city compoent
			 * @param  {Object} city City object with attributes city_code and name
			 * @return {string}      HTML link with city-name class name and link to the city
			 */
			var cityLink = function(city) {
				/* jshint camelcase:false */
				return '<a class="city-name" href="/' + city.city_code + '">' + city.name + '</a>';
			}

			/**
			 * Create a city link with background filter component
			 * @param  {Object} city [description]
			 * @return {string}      HTML link with background filter class and link to city
			 */
			var cityLinkBg = function(city) {
				/* jshint camelcase:false */
				return '<a class="background-filter" href="/' + city.city_code + '">' + city.name + '</a>';
			};

			/**
			* Adds 'loading' class to cities-partial element
			*/
			var setLoading = function() {
				$('.cities-partial').addClass('loading');
			}

			/**
			* Removes 'loading' class to cities-partial element
			*/
			var unsetLoading = function() {
				$('.cities-partial').removeClass('loading');
			}

			/**
			 * Loads City Data received from API (TODO refactor method)
			 * @param  {object} data Response from API call
			 * @return {function}      Unsets loading
			 */
			var loadCitiesData = function (data) {
				var cities = _(data.cities).chain()
					.sortBy(function(c) {
						/* jshint camelcase:false */
						return c.info.user_count;
					}).reverse()
					.sortBy(function(c) {
						/* jshint camelcase:false */
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
					var cityDiv = '<div class="city"><div class="city-image" style="background: url(' + city.header_bg_small + ') no-repeat 50% 50%; background-size: cover;"><h2 class=" city-name">' + cityLinkBg(city) + cityLink(city) + '</h2></div></div>';
					if (city.brew_status === 'fully_brewed') {
						listOfActiveCities.push(cityDiv);
					} else if (!(city.brew_status === 'unapproved') && !(city.brew_status === 'hidden')) {
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
			if (!user_info) {
				return;
			}

			if (user_info.leading) {
				leading_button.addClass('applied');
			}

			if (user_info.hosting) {
				hosting_button.addClass('applied');
			}

		});

		[leading_button, hosting_button].forEach(function(btn) {
			btn.on('click', function(evt) {
				var type = evt.currentTarget.dataset.userInterest;
				var data = {
					'tws_interests': {}
				};
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

	fns.forEach(function(e, i) {
		$(document).ready(e)
		$(document).on('page:load', e)
	});
}());

$(function() {
	'use strict';
	var setLoading,
		unsetLoading,
		onCitiesIndexLoad,
		onCitiesShow,
		initializeFunctions;

	/**
	 * Set loading by adding a loading class to cities partials element selector
	 */
	setLoading = function() {
		$('.cities-partial').addClass('loading');
	};

	/**
	 * Remove loading by removing a loading class to cities partials element selector
	 */
	unsetLoading = function() {
		$('.cities-partial').removeClass('loading');
	};

	/**
	 * Load the cities in
	 */
	onCitiesIndexLoad = function() {
		if (window.location.pathname === '/cities/' ||
			window.location.pathname === '/cities') {

			var listOfActiveCities = [],
				listOfUpcomingCities = [],
				cityLink,
				cityLinkBg;

			/**
			 * Returns link of city given city object
			 * @param  {object} city City object
			 * @return {string}      HTML string linking each city
			 */
			cityLink = function(city) {
				/*jshint camelcase: false */
				return '<a class="city-name" href="/' + city.city_code + '">' + city.name + '</a>';
			};

			/**
			 * Returns link of city given city object & a background filter
			 * @param  {object} city City object
			 * @return {string}      HTML string linking each city
			 */
			cityLinkBg = function(city) {
				/*jshint camelcase: false */
				return '<a class="background-filter" href="/' + city.city_code + '">' + city.name + '</a>';
			};

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
					.value();

				$.each(cities, function(index, city) {
					/*jshint camelcase: false */
					var cityDiv = '<div class="city"><div class="city-image" style="background: url(' + city.header_bg + ') no-repeat 50% 50%; background-size: cover;"><h2 class=" city-name">' + cityLinkBg(city) + cityLink(city) + '</h2></div></div>';
					if (city.brew_status === 'fully_brewed') {
						listOfActiveCities.push(cityDiv);
						/*jshint camelcase: false */
					} else if ((city.brew_status !== 'unapproved') && (city.brew_status !== 'hidden') && (city.brew_status !== 'rejected')) {
						listOfUpcomingCities.push(cityDiv);

					}
				});
				$('.current-cities-container').html(listOfActiveCities.join(' '));
				$('.upcoming-cities-container').html(listOfUpcomingCities.join(' '));

				unsetLoading();
			});
		}
	};

	onCitiesShow = function() {
		/*jshint camelcase: false */
		var leading_button = $('a[data-user-interest="leading"]'),
			hosting_button = $('a[data-user-interest="hosting"]'),
			buttons = [leading_button, hosting_button];

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

		buttons.forEach(function(btn) {
			btn.on('click', function(evt) {
				evt.preventDefault();
				var type = evt.currentTarget.dataset.userInterest;
				var data = {
					'tws_interests': {}
				};
				/*jshint camelcase: false */
				data.tws_interests[type] = true;
				$.ajax({
					url: '/api/v1/users/self/interests',
					type: 'PATCH',
					data: data,
					success: function() {
						$(evt.currentTarget).addClass('applied', 'disabled');
					}
				});
			});
		});
	};

	initializeFunctions = [onCitiesIndexLoad, onCitiesShow];

	initializeFunctions.forEach(function(func) {
		$(document).ready(func);
		$(document).on('page:load', func);
	});
});

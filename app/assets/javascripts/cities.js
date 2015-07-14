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
        success: function(d) {
          $(evt.currentTarget).addClass('applied', 'disabled')
        }
      });
    });
  });
}

$(document).ready(onCitiesShow);
$(document).on('page:load', onCitiesShow);
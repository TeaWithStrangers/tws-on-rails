var markLeadingButton = function() {
  var leading_button = $('a[data-user-interest="leading"]');
  leading_button.addClass('applied');
}

// On the city page, just change the class
// on the hosting page, remove the button and show a div
var markHostingButton = function() {
  var hosting_button = $('a[data-user-interest="hosting"]');
  if (window.location.pathname.match(/cities/)) {
    hosting_button.addClass('applied');
  } else if (window.location.pathname.match(/hosting/)) {
    hosting_button.css('display', 'none');
    var hosting_interest = $('.interested-in-hosting.hidden')
    hosting_interest.removeClass('hidden');
  }
}

var bindInterestButtons = function() {
  var leading_button = $('a[data-user-interest="leading"]');
  var hosting_button = $('a[data-user-interest="hosting"]');

  [leading_button, hosting_button].forEach(function(btn) {
    btn.on('click', function(evt) {
      evt.preventDefault();
      var type = evt.currentTarget.dataset.userInterest;
      var data = {
        'tws_interests': {}
      };

      data.tws_interests[type] = true;

      $.ajax({
        url: '/api/v1/users/self/interests',
        type: 'PATCH',
        data: data,
        success: function(d) {
          if (type === 'leading') {
            markLeadingButton();
          } else if (type === 'hosting') {
            markHostingButton();
          }
        }
      });
    });
  });
}

var getInterests = function() {
  $.get('/api/v1/users/self/interests', function(user_info) {
    if (!user_info) { return; }

    if (user_info.leading) {
      markLeadingButton();
    }

    if (user_info.hosting) {
      markHostingButton();
    }
  });
}

if (window.location.pathname.match(/cities/) || window.location.pathname.match(/hosting/)) {
  $(document).ready(bindInterestButtons);
  $(document).on('page:load', bindInterestButtons);
  $(document).ready(getInterests);
  $(document).on('page:load', getInterests);
}
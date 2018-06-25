/**
 * Bind the tea time month navigation links (e.g. "see next month tea times")
 */
var bindTeaTimeMonthLink = function() {
  $('#tea-time-month-next').on('click', function(e) {
    e.preventDefault();
    $(this).closest('.month-display-container').removeClass('show-left').addClass('show-right');
  });

  $('#tea-time-month-prev').on('click', function(e) {
    e.preventDefault();
    $(this).closest('.month-display-container').removeClass('show-right').addClass('show-left');
  });
};

$(document).on('turbolinks:load', bindTeaTimeMonthLink)

$(function() {
  'use strict';

  /**
   * Mark attendance activation after email send callback
   */
  function toggleEventAttendance(e) {
    var form,
      onAttendanceSuccess,
      onAttendanceError,
      sendAttendanceForm;
    /**
     * Callback for toggle event attendance ajax response success
     * @param  {object} data data from API Callback
     */
    onAttendanceSuccess = function(data) {
      /*jshint camelcase: false */
      var id = data.tea_time.id;
      /*jshint camelcase: true */

      // Add class `tasks email complete` to the data-teatime id, selected from the h3.tasks.email chained selector
      $('[data-tea-time-id=' + id + '] > h3.tasks.email')
        .attr('class', 'tasks email complete');

      // Add subtask container to custom message
      $(e.target)
        .parents('.subtask-container')
        .html('<p class="subtask">All done, thanks!</p>');
    };

    /**
     * Callback for toggle event attendance ajax response failure
     */
    onAttendanceError = function() {
      // alert('Uh-oh. You shouldn\'t be seeing this.');
      // TODO log error (not good in production code)
    };

    /**
     * AJAX call to the form method sending JSON
     * @param  {element} form form element with all its inputs
     */
    sendAttendanceForm = function(form) {
      $.ajax({
        type: form.attr('method'),
        url: form.attr('action'),
        contentType: 'application/json',
        data: form.serialize(),
        dataType: 'json',
        success: onAttendanceSuccess,
        error: onAttendanceError
      });
    };

    // Prevent Default Action
    e.preventDefault();

    // Form element
    form = $(e.target.form);

    // Send attendance form to server
    sendAttendanceForm(form);
  }

  // Initialization and Event Hook-ups
  $(document).ready(function() {
    $('.email-sent-button').on('click', toggleEventAttendance);
  });
  $(document).on('page:load', toggleEventAttendance);

});
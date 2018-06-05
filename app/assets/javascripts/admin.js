// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
function adminReady() {
  // Attach refresh page handler
  $('#segment-form-refresh-page').off('click').on('click', function(e) {
    e.preventDefault();
    location.reload();
  });

  // Attach refresh recipients handler
  $('#segment-form-info-total-recipients-refresh').off('click').on('click', function(e) {
    e.preventDefault();

    // Collect segments
    params = {
      'segments[]': $('#segment_segments').val()
    };

    // Hide refresh, show spinner
    $('#segment-form-info-total-recipients-refresh').hide();
    $('#segment-form-info-total-recipients-spinner').show();

    $.post('/admin/segment_count', params, function(data) {
      // Hide spinner, show count
      $('#segment-form-info-total-recipients-spinner').hide();
      $('#segment-form-info-total-recipients-count')
        .text(data)
        .show();
    });
  });

  // Attach chosen change handler
  $('#segment_segments').chosen().change(function (e) {
    // Hide count, show refresh
    $('#segment-form-info-total-recipients-refresh').show();
    $('#segment-form-info-total-recipients-count').hide();
  })
}

// $(document).ready(adminReady)
// $(document).on('page:load', adminReady)
$(document).on('turbolinks:load', adminReady)

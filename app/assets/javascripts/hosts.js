// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// Yes, to whoever is reading this, I do hate myself. -nb Sat Jan 10 15:05:45
// Sorry.


function attendanceMarkingActivtion() {
  $('.email-sent-btn').on('click', function(evt) {
    evt.preventDefault();
    console.log(evt);
    var form = $(evt.target.form);
    $.ajax({
      type: form.attr('method'),
      url: form.attr('action'),
      data: form.serialize(),
      dataType: 'json', //Not sure why this is required
      success: function(data) {
        var id = data.tea_time.id;
        $("[data-tea-time-id='"+id+"'] > h3.tasks.email").attr('class', 'tasks email complete')
        $(evt.target).parents('.subtask-container').html("<p class='subtask'>All done, thanks!</p>")
      },
      error: function(data) { alert('Uh-oh. You shouldn\'t be seeing this.'); }
    });
  });
}

$(document).ready(attendanceMarkingActivtion)
$(document).on('page:load', attendanceMarkingActivtion)

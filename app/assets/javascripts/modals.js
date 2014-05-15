var modal;
function loadModal(modalTarget) {
  return function(evt) {
    evt.preventDefault();
    return $("#modal").load(modalTarget).dialog({
      modal: true,
      draggable: false,
      resizeable: false,
      width: 500,
      title: null
    });
  }
}
function closeModal() { modal.dialog('close') }
function ready() {
  $('#login').click(loadModal('/signin'));
  $('.tea-time-scheduling').on('click', function(evt) {
    modal = loadModal(evt.currentTarget.href)(evt)
  });
  $('a.cancel').on('click', function(evt) {
    console.log(evt)
    evt.preventDefault();
    closeModal();
  })
}

$(document).ready(ready)
$(document).on('page:load', ready)

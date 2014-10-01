var minimumWidthToDisplayModal = 768;
var modal;

function loadModal(modalTarget) {
  console.log(viewportWidth());
  if(viewportWidth() < minimumWidthToDisplayModal) {
    return function(evt) { console.debug("Modal not displayed because minimum width not met") }
  }

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
  $('#login').on('click', function(evt) { 
    loadModal('/signin')(evt)
  });

  $('.edit_attendance , .tea-time-scheduling').on('click', function(evt) {
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

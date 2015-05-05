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
      position: { my: "center top", at: "center top", of: evt.target },
      modal: true,
      draggable: false,
      resizeable: false,
      width: 500,
      closeText: "Not now",
      title: ''
    });
  }
}
function closeModal() { modal.dialog('close') }

function modalActivation() {
  $('a.sign-up').on('click', function(evt) { 
    modal = loadModal('/signup')(evt)
  });

  //$('#login').on('click', function(evt) { 
  //  modal = loadModal('/signin')(evt)
  //});

  $('.edit_attendance, .tea-time-scheduling').on('click', function(evt) {
    modal = loadModal(evt.currentTarget.href)(evt)
  });

  $('a.cancel').on('click', function(evt) {
    console.log(evt)
    evt.preventDefault();
    closeModal();
  })
}

$(document).ready(modalActivation)
$(document).on('page:load', modalActivation)

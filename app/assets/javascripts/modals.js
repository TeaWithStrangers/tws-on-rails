$(function() {
  'use strict';
  var modal,
    viewportWidth,
    loadModal,
    closeModal,
    modalActivation;

  /**
   * get viewport width
   * @return {int} width of the viewport
   */
  viewportWidth = function() {
    return (window.innerWidth > 0) ? window.innerWidth : screen.width;
  };

  /**
   * Load modals with given modalTarget
   * @param  {string} modalTarget modal target element selector
   * @return {callback}             function that generates modal
   */
  loadModal = function(modalTarget) {
    var minimumWidthToDisplayModal = 768;
    /**
     * Generate a modal window from jQuery
     * @param  {object} evt browser event object
     * @return {callback}     function that loads a modal from the modal target
     */
    var generateModal = function(evt) {
      evt.preventDefault();

      return $('#modal').load(modalTarget).dialog({
        position: {
          my: 'center top',
          at: 'center top',
          of: evt.target
        },
        modal: true,
        draggable: false,
        resizeable: false,
        width: 500,
        closeText: 'Not now',
        title: ''
      });
    };

    // console.log(viewportWidth());
    if (viewportWidth() < minimumWidthToDisplayModal) {
      return function() {
        // console.debug("Modal not displayed because minimum width not met")
      };
    }

    return generateModal;
  };

  /**
   * Close modal window
   */
  closeModal = function() {
    modal.dialog('close');
  };

  /**
   * Activate Modal Callbacks
   */
  modalActivation = function() {
    // $('.sign-up-emphasis').on('click', function(evt) {
    //   if ($(evt.currentTarget).attr('href') === '/signup') {
    //     modal = loadModal('/signup')(evt);
    //   }
    // });

    $('.tea-time-scheduling').on('click', function(evt) {
      modal = loadModal(evt.currentTarget.href)(evt);
    });

    $('.cities.show a.cancel').on('click', function(evt) {
      // console.log(evt);
      evt.preventDefault();
      closeModal();
    });
  };

  // Initialization of Modal
  $(document).ready(modalActivation);
  $(document).on('page:load', modalActivation);
});

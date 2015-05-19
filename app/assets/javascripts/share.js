// Index for the current share item
var currentShareItem = 0;

// Bootstrap the share system
var shareBootstrap = function() {
  // Set click behavior of the "Try This On For Size" button
  $('.sharing-try-button').on('click', function(e) {
    // Advance share item index
    currentShareItem++;

    // Check if we went past the last item in the collection
    if (SHARE_COLLECTION.length == currentShareItem) {
      // Last item reached, loop back to 0
      currentShareItem = 0;
      if ($('.sharing-try-button-text').text() == 'How about another?') {
        $('.sharing-try-button-text').text('Ok now share')
      }
    }

    // Get share item at position in the collection
    var shareItem = SHARE_COLLECTION[currentShareItem];

    // Inject image tag into image preview
    $('#sharing-preview-image').attr('src', shareItem.img)

    // Inject text into content preview
    $('#sharing-preview-text-content').text(shareItem.text)

    // Inject the url into the Facebook share
    $('.sharing-facebook-button').attr('href', 'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(shareItem.url) + '&display=popup&ref=plugin')

    // Run animation again: Remove class
    $('.sharing-preview').removeClass('sharing-preview-bounce')
    // Reflow
    document.getElementById('sharing-preview').offsetHeight;
    // Add class back in
    $('.sharing-preview').addClass('sharing-preview-bounce')

    // Change sharing try text if it hasn't already
    if ($('.sharing-try-button-text').text() == 'Try this on for size') {
      $('.sharing-try-button-text').text('How about another?')
    }

    // Remove the blurb if it hasn't already
    if ($('.sharing-try-blurb').is(":visible")) {
      $('.sharing-try-blurb').hide()
    }

    // Prevent default (#)
    e.preventDefault();
  });

  // Set click behavior of sharing buttons
  // - Facebook
  // - Twitter
  // - Tumblr
  $('.sharing-button').on('click', function(e) {
    // Open a popup with the share sheet
    sharePopup($(this).attr('href'))

    // Prevent default
    e.preventDefault();
  })
}

// Popup open function
var sharePopup = function(url) {
  // Calculate screen dimensions to put window at center
  var left = (screen.width/2)-(600/2);
  var top = (screen.height/2)-(400/2);

  window.open(url, "_blank", "toolbar=no, scrollbars=yes, resizable=yes, width=600, height=400, top=" + top + ", left=" + left);
}
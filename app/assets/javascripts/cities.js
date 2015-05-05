var danCallThisFunction = function() {
  console.log('working?');
};


$(document).ready(danCallThisFunction)
$(document).on('page:load', danCallThisFunction)

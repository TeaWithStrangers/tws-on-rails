var bindCommitmentForm = function() {
  var form = $('#commitment-form');
  var input = $('#commitment-regular');
  updateCommitmentForm();
  form.on('change', updateCommitmentForm);
  updateCustomField()
  form.on('change', updateCustomField)
}

updateCommitmentForm = function() {
  var buttons = $('#nested-radio-buttons');
  var inputs = buttons.find('input');
  if($('#commitment-regular').is(':checked')) {
    buttons.removeClass('faded');
    inputs.each(function(i, input) {
      input.disabled = false;
    })
  } else {
    buttons.addClass('faded');
    inputs.each(function(i, input) {
      input.disabled = true;
      input.checked = false;
    });
  }
}

updateCustomField = function() {
  var input = $('#custom-commitment');
  if($('#user_commitment_detail_custom').is(':checked')) {
    input.prop('disabled', false);
  } else {
    input.prop('disabled', true);
    $("#custom-commitment").val("");
  }
}

$(document).ready(bindCommitmentForm);
$(document).on('page:load', bindCommitmentForm);

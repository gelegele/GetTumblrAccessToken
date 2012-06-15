/**
 * javascript by gelegele
 */

/**
 * Submit form after validation.
 */
function submitForm(button) {
  var invalid = false;
  jQuery('input').each(function(i) {
    if ($(this).val().length == 0) {
      var divControlGroup = $(this).parent().parent();
      divControlGroup.attr('class', 'control-group error');
      invalid = true;
    }
  });
  if (!invalid) {
    $('form').submit();
  }
}

/**
 * Clear color after validation error.
 */
$(function(){
  $('input').keyup(function() {
    if (0 < $(this).val().length) {
      var divControlGroup = $(this).parent().parent();
      divControlGroup.attr('class', 'control-group');
    }
  });
});

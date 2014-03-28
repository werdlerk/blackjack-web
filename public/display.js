$(document).ready(function() {
  $("#make_bet").modal('show');

  $("#make_bet .btn-primary").click(function() {
    $.ajax("/make_bet", {
      data: { bet_amount: $("#make_bet #bet_amount").val() }
    }).done(function(response) {
      $("#current_bet").html(response);
    });

    ;
  });
});

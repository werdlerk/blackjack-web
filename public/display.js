function renderPlayerCards() {
  $.ajax({
    type: 'GET',
    url: '/ajax/player_cards'
  }).done(function(data) {
    $("#player_cards").replaceWith(data);
  });
}

function renderDealerCards() {
  $.ajax({
    type: 'GET',
    url: '/ajax/dealer_cards'
  }).done(function(data) {
    $("#dealer_cards").replaceWith(data);
  });
}

function handleGameData(gamedata) {
  if (gamedata.state == 'player') {
    renderPlayerCards();
  }

  if (gamedata.state == 'dealer') {
    renderDealerCards();

    $("#action_buttons").hide();

    // every second do dealer card
    setTimeout("postGameData('dealer')", 2000);
    
  } else if (gamedata.state == 'player_win' || gamedata.state == 'player_lost' || gamedata.state == 'tie') {
    renderPlayerCards();
    renderDealerCards();

    $("#action_buttons").hide();

    $("#alert-spacing").remove();

    if (gamedata.error != null)
      $("body > .container").prepend( "<div class='alert alert-error'>" + gamedata.error + "</div>");
    if (gamedata.success != null) 
      $("body > .container").prepend( "<div class='alert alert-success'>" + gamedata.success + "</div>");
    if (gamedata.info != null)
      $("body > .container").prepend( "<div class='alert alert-info'>" + gamedata.info + "</div>");
  }

}

function postGameData(actionName) {
  $.ajax({
    type: 'POST',
    url: '/ajax/game',
    data: { action : actionName }
  }).done(handleGameData);
}

$(document).ready(function() {
  renderPlayerCards();
  renderDealerCards();

  // Get current game state
  postGameData('current');

  // Hit & Stay buttons
  $("#action_buttons input.btn").click(function(){
    postGameData($(this).val());
    return false;
  });
});

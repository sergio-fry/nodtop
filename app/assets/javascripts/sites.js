$(function() {
  $(".sites-table").each(function() {
    var table = $(this);
    var rating_total = 0;
    table.find(".site").each(function(){ rating_total += parseFloat($(this).data("rating")) });

    table.find(".site").each(function(){
      var share = parseFloat($(this).data("rating")) / rating_total;
      console.log(share);
      $(this).find(".share").html(Math.round(share * 10000) / 100 + "&nbsp;%");
    });
  });
});

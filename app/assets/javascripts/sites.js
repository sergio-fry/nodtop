$(function() {
  $(".sites-table:first").each(function() {
    var table = $(this);
    var rating_total = 0;
    table.find(".site").each(function(){ rating_total += parseFloat($(this).data("rating")) });

    table.find(".site").each(function(){
      var share = parseFloat($(this).data("rating")) / rating_total;
      $(this).find(".share").html(Math.round(share * 10000) / 100 + "&nbsp;%");
    });
  });

  $("#new_site_form").each(function() {
    var submit_button = $(this).find(":input[type='submit']").attr("disabled", "disabled");
    var form = $(this);

    var update_submit = function() {
      // когда все галки стоят - разрешаем регистрацию
      if(form.find(":input:checkbox:checked").length == form.find(":input:checkbox").length) {
        submit_button.attr("disabled", null);
      } else {
        submit_button.attr("disabled", "disabled");
      }
    }

    update_submit();

    $(this).find(":input[type='checkbox']").change(function() {
      update_submit();
    });
  });
});

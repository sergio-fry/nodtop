// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .


$(function() {
  $(".site-widget-code").each(function() {


    var domain = $(this).data("domain");
    var request = $.ajax({
      url: 'https://www.googleapis.com/urlshortener/v1/url',
      type: 'POST',
      contentType: 'application/json; charset=utf-8',
      data: '{ longUrl: "' + "http://rusnod.github.io/lenta/javascripts/lenta.min.js?ref="+ domain +'"}',
      dataType: 'json',
      success: function(data) {
        short_url = data.id;
      }
    });

    var el = $(this);

    request.done(function(data) {
      var code = '';

      code = code + '<!-- Участник рейтинга сайтов НОД http://nodtop.russianpulse.ru/ -->' + "\n";
      code = code + '<script src="'+data.id+'"></script>' + "\n";
      code = code + '<script>';
      code = code + 'LentaNOD.init({ corner: "top_right" });';
      code = code + '</script>';
      el.val(code).removeClass("hidden").show();
    });


  });
});

require 'uglifier'

class CounterController < ApplicationController
  def code
    js = <<-JS
    window.NODTop = {};
    var NODTop = window.NODTop;

    NODTop.init = function(options) {
      document.write('<script src="http://goo.gl/'+options.counter_id+'"></script>');
      document.write('<script> LentaNOD.init({}) </script>');
    };
    JS

     render :js => Uglifier.compile(js), :content_type => 'application/javascript' 
  end
end

module ApplicationHelper
  def metric_graph(metric, title=nil)
    if metric.blank? || metric.data_set.blank?
      "Нет данных"
    else
      concat content_tag(:div, nil, :id => "metric_graph_#{metric.id}")

      concat javascript_tag <<-JS
      g = new Dygraph(

        // containing div
        document.getElementById("metric_graph_#{metric.id}"),

        // CSV or path to a CSV file.
        "Date,#{title || metric.title}\\n" +

        #{raw metric.data_set.sort_by{ |d| d[:date] }.map{ |d| "\"#{d[:date].strftime("%Y-%m-%d %H:%M")},#{d[:value]}\\n\"" }.join(" + ")}
      );
      JS
    end
  end
end

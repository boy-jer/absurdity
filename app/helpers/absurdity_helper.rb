module AbsurdityHelper

  def metric_info(metrics, metric, count)
    str  = "#{metric.to_s.humanize}"
    str += ": #{count} "
    # str += metric_ratios(metrics, metric, count)
  end

  def completed_text(completed)
    if completed == :completed
      "(Completed)"
    elsif completed
      "(Completed: #{completed})"
    else
      ""
    end
  end

  private

  def metric_ratios(metrics, metric, count)
    ratios = metrics.map do |other_metric, other_count|
      if metric != other_metric && count != 0 && other_count != 0
        str = "#{metric.to_s.humanize}/#{other_metric.to_s.humanize} :"
        str += " #{number_to_percentage((count.to_f/other_count.to_f)*100, precision: 3)}"
        str
      end
    end.compact
    ratios.present? ? "(" + ratios.join(",") + ")" : ""
  end
end

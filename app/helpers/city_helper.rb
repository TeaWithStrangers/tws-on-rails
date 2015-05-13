module CityHelper
  def progress_bar(val, max)
    raw(render partial: 'cities/show/progress_bar', locals: {val: val, max: max})
  end
end

module CityHelper
  def progress_bar(val, max)
    raw(render partial: 'cities/show/progress_bar', locals: {val: val, max: max})
  end

  def tea_spots_progress_bar(val, max)
    raw(render partial: 'cities/show/tea_spots_progress_bar', locals: {val: val, max: max})
  end
end

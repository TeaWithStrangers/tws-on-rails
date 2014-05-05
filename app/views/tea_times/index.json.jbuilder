json.array!(@tea_times) do |tea_time|
  json.extract! tea_time, :id
  json.url tea_time_url(tea_time, format: :json)
end

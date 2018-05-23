module StaticHelper
  def next_step_path
    if current_user.nil?
      sign_up_path
    else
      tea_times_path
    end
  end
end

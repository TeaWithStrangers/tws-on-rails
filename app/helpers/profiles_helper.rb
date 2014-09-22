module ProfilesHelper
  def display_button?(assigns)
    (assigns.key?(:without_button) && assigns[:without_button] == false) ? false : true
  end

end

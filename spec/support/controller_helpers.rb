module ControllerHelpers
  def referer(ref)
    @request.env['HTTP_REFERER'] = ref
  end
end

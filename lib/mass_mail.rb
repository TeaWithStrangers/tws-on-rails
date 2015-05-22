# An object used to generate a form in the admin interface.
class MassMail
  include ActiveModel::Model

  ATTRIBUTES = %i(from to subject city_id body)
  attr_accessor *ATTRIBUTES
  validates_presence_of :subject, :body, :city_id

  def initialize(attributes = {})
    attributes.each do |name, value|
      if !value.blank?
        send("#{name}=", value)
      end
    end
  end

  def to_hash
    ATTRIBUTES.inject({}) do |hsh, k|
      hsh[k] = send(k.to_s)
      hsh
    end
  end
  def persisted?
    false
  end
end
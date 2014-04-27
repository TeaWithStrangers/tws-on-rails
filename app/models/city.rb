class City < ActiveRecord::Base
  validates_uniqueness_of :city_code
  enum brew_status: { :cold_water => 0, :warming_up => 1, :fully_brewed => 2}
  has_many :tea_times

  def to_param
    city_code
  end

  class << self
    def for_code(code)
      for_code_proxy(code, :find_by)
    end

    def for_code!(code)
      for_code_proxy(code, :find_by!)
    end

    private
      def for_code_proxy(code, method)
        self.send(method, city_code: code.upcase)
      end
  end
end

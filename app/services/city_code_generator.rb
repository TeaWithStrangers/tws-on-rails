# putting this in a separate class because
# I expect that we can make this logic smarter
# and use the name of the city to generate a code
class CityCodeGenerator
  def self.generate
    SecureRandom.hex(4)
  end
end
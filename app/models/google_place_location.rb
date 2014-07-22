class GooglePlaceLocation

  attr_accessor :name, :latitude, :longitude, :formatted_address

  def initialize
  end

  def to_s
    "#{name} @ #{formatted_address}: #{latitude}, #{longitude}"
  end

  def self.loadFromJson(data)
    location = GooglePlaceLocation.new
    location.name = data['name']
    location.formatted_address = data['formatted_address']

    if data['geometry'] && data['geometry']['location']
      location.latitude = data['geometry']['location']['lat']
      location.longitude = data['geometry']['location']['lng']
    end

    location
  end

end

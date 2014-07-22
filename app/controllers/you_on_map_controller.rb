class YouOnMapController < UIViewController

  ELEVATION_UPDATE_THRESHOLD = 10 # seconds

  def viewWillAppear(animated)
    super

    #== State
    @timeOfLastUpdate = 0
    @lastKnownCoordinate = nil
    @applicationFrameSize = UIScreen.mainScreen.applicationFrame.size
    @elevationBoxWidth = (@applicationFrameSize.width * 0.40).ceil

    #== UI properties
    self.title = "You"
    self.view.backgroundColor = UIColor.whiteColor

    #== Utility
    @elevationClient = GoogleElevationClient.instance
    @numberFormatter = NSNumberFormatter.alloc.init
    @numberFormatter.numberStyle = NSNumberFormatterDecimalStyle
    @numberFormatter.setMaximumFractionDigits(0)

    #== UI elements
    @mapView = MKMapView.alloc.init
    @mapView.delegate = self
    @mapView.scrollEnabled = true
    @mapView.zoomEnabled = true
    @mapView.showsUserLocation = true
    @mapView.frame = CGRectMake(0, 20, @applicationFrameSize.width, @applicationFrameSize.height)
    self.view.addSubview(@mapView)

    createInfoBox!
    loadCurrentLocation

    true
  end

  def performUpdateFromElevationApi?
    (Time.now.to_i - @timeOfLastUpdate) > ELEVATION_UPDATE_THRESHOLD
  end

  def viewWillDisappear(animated)
    super

    BW::Location.stop
  end

  def loadCurrentLocation
    BW::Location.get do |result|
      if result[:to]
        @lastKnownCoordinate = result[:to].coordinate
        LocalStorageUtil.set("currentLatitude", @lastKnownCoordinate.latitude)
        LocalStorageUtil.set("currentLongitude", @lastKnownCoordinate.longitude)
        if performUpdateFromElevationApi?
          updateMapWithLocation
        end
      end
    end
  end

  def updateMapWithLocation()
    region = MKCoordinateRegionMakeWithDistance(@lastKnownCoordinate, 500, 500)
    @mapView.setRegion(region, animated:true)
    updateElevationLabels
    @timeOfLastUpdate = Time.now.to_i
  end

  def createInfoBox!
    box = UIView.alloc.init
    box.backgroundColor = '#ADFBA6'.to_color
    box.layer.cornerRadius = 4.0
    box.layer.borderWidth = 2.0
    box.layer.borderColor = UIColor.blackColor

    xOffset = (@applicationFrameSize.width - @elevationBoxWidth) / 2.to_f
    box.frame = CGRectMake(xOffset, 40, @elevationBoxWidth, 46)

    infoLabel = UILabel.alloc.init
    infoLabel.text = "Elevation"
    infoLabel.font = UIFont.boldSystemFontOfSize(14)
    infoLabelSize = infoLabel.sizeThatFits(CGSizeMake(100, CGFLOAT_MAX))
    xInfoLabelOffset = (@elevationBoxWidth - infoLabelSize.width) / 2.to_f
    infoLabel.frame = CGRectMake(xInfoLabelOffset, 2, infoLabelSize.width, infoLabelSize.height)

    @elevationValue = UILabel.alloc.init
    @elevationValue.text = "Obtaining"
    @elevationValue.textColor = UIColor.blueColor
    @elevationValue.font = UIFont.systemFontOfSize(16)
    elevationValueLabelSize = @elevationValue.sizeThatFits(CGSizeMake(100, CGFLOAT_MAX))

    xInfoOffset = (@elevationBoxWidth - elevationValueLabelSize.width) / 2.to_f
    @elevationValue.frame = CGRectMake(xInfoOffset, infoLabelSize.height + 8,
      elevationValueLabelSize.width, elevationValueLabelSize.height)

    box.addSubview(infoLabel)
    box.addSubview(@elevationValue)

    self.view.addSubview(box)
  end

  def updateElevationLabels
    lat = @lastKnownCoordinate.latitude
    lng = @lastKnownCoordinate.longitude

    puts "Discovering: #{lat},#{lng}"
    @elevationClient.fetch(lat,lng) do |json|
      updateElevation!(json['results'][0]['elevation'])
    end
  end

  def updateElevation!(elevationDecimal)
    feet = ConversionUtil.metersToFeet(elevationDecimal)
    puts "Found: #{feet}"
    Dispatch::Queue.main.async do
      value = @numberFormatter.stringFromNumber(feet)
      @elevationValue.text = "#{value} ft."
      size = @elevationValue.sizeThatFits(CGSizeMake(100, CGFLOAT_MAX))
      xOffset = (@elevationBoxWidth - size.width) / 2.to_f
      frame = @elevationValue.frame
      frame.size.width = size.width
      frame.origin.x = xOffset
      @elevationValue.frame = frame
    end
  end

end

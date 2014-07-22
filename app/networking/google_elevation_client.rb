class GoogleElevationClient

  def self.instance
    Dispatch.once do
      @instance ||= new
    end
    @instance
  end

  def initialize
    sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration
    sessionConfig.allowsCellularAccess = true
    sessionConfig.setHTTPAdditionalHeaders({'Accept' => 'application/json'})

    @session = NSURLSession.sessionWithConfiguration(sessionConfig, delegate:self, delegateQueue:nil)
  end

  def fetch(lat, lng, &callback)
    urlWithValues = "https://maps.googleapis.com/maps/api/elevation/json?locations=#{lat},#{lng}&key=#{GoogleConfig::ELEVATION_API_KEY}"
    url = NSURL.URLWithString(urlWithValues)

    handler = Proc.new do |data, response, urlFetchErrorPtr|
      if urlFetchErrorPtr
        Dispatch::Queue.main.async do
          message = urlFetchErrorPtr.userInfo['NSLocalizedDescription']
          App.alert(message)
        end
      else
        jsonDecodeErrorPtr = Pointer.new(:object)
        json = NSJSONSerialization.JSONObjectWithData(data, options:0, error:jsonDecodeErrorPtr)
        callback.call(json)
      end
    end

    task = @session.dataTaskWithURL(url, completionHandler:handler)
    task.resume
  end
end

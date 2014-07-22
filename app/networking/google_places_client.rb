class GooglePlacesClient

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

  def search(query, &callback)
    query = query.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)
    urlWithValues = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{query}&key=#{GoogleConfig::PLACES_API_KEY}"
    url = NSURL.URLWithString(urlWithValues)
    handler = Proc.new do |data, response, error|
      errorPtr = Pointer.new(:object)
      json = NSJSONSerialization.JSONObjectWithData(data, options:0, error:errorPtr)
      callback.call(json)
    end
    task = @session.dataTaskWithURL(url, completionHandler:handler)
    task.resume
  end

end

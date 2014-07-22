class SearchPlacesController < UITableViewController

  attr_accessor :searchResults, :searchBar, :delegate, :isLoading
  attr_accessor :slot # :source or :destination

  def viewWillAppear(animated)
    super

    self.title = "Search Places"
    @searchResults ||= []
    @slot ||= :source

    # make a dummy location to represent our current location
    @currentLocation = GooglePlaceLocation.new
    @currentLocation.name = "Current Location"
    @currentLocation.latitude = LocalStorageUtil.get("currentLatitude")
    @currentLocation.longitude = LocalStorageUtil.get("currentLongitude")

    self.tableView.delegate = self
    self.tableView.dataSource = self

    @searchBar = UISearchBar.alloc.initWithFrame(CGRectMake(0, 0, 320, 44))
    @searchBar.delegate = self
    @searchBar.text = @searchBarQuery
    self.tableView.tableHeaderView = @searchBar

    true
  end

  def delegate=(delegate)
    @delegate = WeakRef.new(delegate)
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    if @isLoading
      return 1
    else
      @searchResults.count + 1
    end
  end

  def loadingCell
    cell = LoadingTableViewCell.alloc.init
    cell.configure
    cell
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    if @isLoading
      return loadingCell
    else
      cellIdentifier = "PlaceResultCell"
      cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)

      if cell == nil
        cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: cellIdentifier)
      end

      if indexPath.row == 0
        location = @currentLocation
      else
        location = @searchResults[indexPath.row - 1]
      end

      cell.textLabel.text = location.name
      cell.textLabel.textColor = UISettings.highlightTextColor
      cell.detailTextLabel.text = location.formatted_address
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

      return cell
    end
  end

  def searchBarSearchButtonClicked(searchBar)
    resetResults!
    searchPlacesWithQuery(searchBar.text)
  end

  def resetResults!
    @searchResults.clear
    self.tableView.reloadData
    @isLoading = true
  end

  def didRetrieveResults
    Dispatch::Queue.main.async do
      @isLoading = false
      self.tableView.reloadData
    end
  end

  def searchPlacesWithQuery(query)
    client = GooglePlacesClient.instance
    client.search(query) do |json|
      if json
        if json['results']
          @searchResults = json['results'].map { |r| GooglePlaceLocation.loadFromJson(r) }
          didRetrieveResults
        end
      end
    end
  end

  # Hide the keyboard when the tableview scrolls
  def scrollViewWillBeginDragging(scrollView)
    @searchBar.resignFirstResponder
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    if indexPath.row == 0
      location = @currentLocation
    else
      location = @searchResults[indexPath.row - 1]
    end
    @delegate.didChooseLocationForSlot(location, @slot)
  end
end

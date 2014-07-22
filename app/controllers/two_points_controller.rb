class TwoPointsController < UIViewController

  attr_accessor :locations, :elevations

  def viewWillAppear(animated)
    super

    self.title = "Gain / Loss"

    #== Data holders
    @locations ||= []
    @elevations ||= []

    #== UI elements
    @scrollView = nil
    @calculateButton = nil
    @gainLossLabel = nil
    @tableView = nil
    @applicationFrameSize = UIScreen.mainScreen.applicationFrame.size

    #== Utility
    @numberFormatter = NSNumberFormatter.alloc.init
    @numberFormatter.numberStyle = NSNumberFormatterDecimalStyle
    @numberFormatter.setMaximumFractionDigits(0)

    @elevationClient = GoogleElevationClient.instance

    #== Create primary [scroll] view
    self.view = createPrimaryScollView!

    createTitleLabel!
    createTableView!
    createResultLabels!

    $s = self
    true
  end

  def createTitleLabel!
    label = UILabel.alloc.init
    label.text = "Determine the Gain/Loss between two points"
    label.font = UIFont.systemFontOfSize(14)
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakByWordWrapping

    maxSize = CGSizeMake(@applicationFrameSize.width, CGFLOAT_MAX)
    requiredSize = label.sizeThatFits(maxSize)
    xOffset = (@applicationFrameSize.width - requiredSize.width) / 2.to_f
    label.frame = CGRectMake(xOffset, 100, requiredSize.width, requiredSize.height)
    self.view.addSubview(label)
  end

  def createPrimaryScollView!
    @scrollView = UIScrollView.alloc.init
    @scrollView.delegate = self
    @scrollView.frame = UIScreen.mainScreen.applicationFrame
    @scrollView.contentSize = CGSizeMake(@applicationFrameSize.width, 800)
    @scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight
    @scrollView.autoresizesSubviews = true
    @scrollView.scrollEnabled = true
    @scrollView.backgroundColor = UISettings.softBackgroundColor

    @scrollView
  end

  def createTableView!
    frame = CGRectMake(0, 120, @applicationFrameSize.width, 88)
    @tableView = UITableView.alloc.initWithFrame(frame, style: UITableViewStylePlain)
    @tableView.dataSource = self
    @tableView.delegate = self
    self.view.addSubview(@tableView)
    true
  end

  # Create a button and add it beneath the tableview
  # def createCalculateButton!
  #   @calculateButton = UIButton.alloc.init
  #   @calculateButton.setTitle("Calculate", forState:UIControlStateNormal)
  #   @calculateButton.setTitleColor(UISettings.buttonTitleColor, forState:UIControlStateNormal)
  #   @calculateButton.setTitleColor(UISettings.buttonPressedTitleColor, forState:UIControlStateHighlighted)
  #   @calculateButton.frame = CGRectMake(0, 220, @applicationFrameSize.width, 40)
  #   @calculateButton.addTarget(self, action:'calculcateGainLoss', forControlEvents:UIControlEventTouchUpInside)
  #   self.view.addSubview(@calculateButton)
  #   true
  # end

  def createResultLabels!
    infoLabel = UILabel.alloc.init
    infoLabel.text = "Gain / Loss:"
    infoLabel.font = UIFont.systemFontOfSize(12)
    infoLabelMaxSize = CGSizeMake(@applicationFrameSize.width, CGFLOAT_MAX)
    infoLabelRequiredSize = infoLabel.sizeThatFits(infoLabelMaxSize)
    infoLabelXOffset = (@applicationFrameSize.width - infoLabelRequiredSize.width) / 2.to_f
    #@gainLossLabel.frame = CGRectMake(xOffset, 100, requiredSize.width, requiredSize.height)

    infoLabel.frame = CGRectMake(infoLabelXOffset, 220, @applicationFrameSize.width, 30)

    self.view.addSubview(infoLabel)

    @gainLossLabel = UILabel.alloc.init
    @gainLossLabel.font = UIFont.systemFontOfSize(16)
    @gainLossLabel.textColor = UISettings.highlightTextColor

    #maxSize = CGSizeMake(@applicationFrameSize.width, CGFLOAT_MAX)
    #requiredSize = @gainLossLabel.sizeThatFits(maxSize)
    #xOffset = (@applicationFrameSize.width - requiredSize.width) / 2.to_f
    #@gainLossLabel.frame = CGRectMake(xOffset, 100, requiredSize.width, requiredSize.height)
    self.view.addSubview(@gainLossLabel)

    updateGainLossLabel!("Unknown - choose points above.")
  end

  def updateGainLossLabel!(text)
    @gainLossLabel.text = text
    maxSize = CGSizeMake(@applicationFrameSize.width, CGFLOAT_MAX)
    requiredSize = @gainLossLabel.sizeThatFits(maxSize)
    frame = @gainLossLabel.frame
    frame.size.width = requiredSize.width
    frame.size.height = requiredSize.height
    frame.origin.x = (@applicationFrameSize.width - requiredSize.width) / 2.to_f
    frame.origin.y = 260
    @gainLossLabel.frame = frame
  end

  def tableView(tableView, numberOfRowsInSection:section)
    2
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cellId = "Cell"
    cell = @tableView.dequeueReusableCellWithIdentifier(cellId)
    if cell.nil?
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: cellId)
    end

    if @locations && !@locations[indexPath.row].nil?
      cell.textLabel.text = @locations[indexPath.row].name
      cell.textLabel.textColor = UISettings.highlightTextColor
      cell.detailTextLabel.text = @locations[indexPath.row].formatted_address
    else
      cell.textLabel.textColor = UIColor.blackColor

      case indexPath.row
      when 0
        cell.textLabel.text = "Source Location"
      when 1
        cell.textLabel.text = "Destination Location"
      end
      cell.textLabel.textColor = UISettings.warningTextColor
    end
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    controller = SearchPlacesController.alloc.initWithStyle(UITableViewStylePlain)
    controller.delegate = self

    if indexPath.row == 0
      controller.slot = :source
    elsif indexPath.row == 1
      controller.slot = :destination
    end

    self.navigationController.pushViewController(controller, animated:true)
  end

  def didChooseLocationForSlot(location, slot, popController = true)
    case slot
    when :source
      @locations[0] = location
      determineElevationForSlot(0, location)
    when :destination
      @locations[1] = location
      determineElevationForSlot(1, location)
    end
    if popController
      self.navigationController.popViewControllerAnimated(true)
    end
    @tableView.reloadData
  end

  def determineElevationForSlot(slotNumber, location)
    @elevationClient.fetch(location.latitude,location.longitude) do |json|
      updateElevationForSlot(slotNumber, json['results'][0]['elevation'])
    end

    # if slotNumber == 0
    #   elevation = 24.1367950439453
    # elsif slotNumber == 1
    #   elevation = 1607.54626464844
    # end
    # updateElevationForSlot(slotNumber, elevation)
  end

  def updateElevationForSlot(slotNumber, elevation)
    case slotNumber
    when 0
      @elevations[0] = elevation
    when 1
      @elevations[1] = elevation
    end
    calculcateDifference!
  end

  def calculcateDifference!
    valid0 = @elevations[0].is_a?(NSNumber)
    valid1 = @elevations[1].is_a?(NSNumber)
    if @elevations.count == 2 && valid0 && valid1
      #puts "source = #{@locations[0]}"
      #puts "destination = #{@locations[1]}"
      #puts "elevation:0 = #{@elevations[0]}"
      #puts "elevation:1 = #{@elevations[1]}"
      Dispatch::Queue.main.async do
        resultInMeters = @elevations[0] - @elevations[1]
        resultInFeet = ConversionUtil.metersToFeet(resultInMeters)
        value = @numberFormatter.stringFromNumber(resultInFeet)
        updateGainLossLabel!("#{value} ft.")
      end
    end
  end

end

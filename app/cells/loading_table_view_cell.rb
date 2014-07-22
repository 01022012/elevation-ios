# http://stackoverflow.com/questions/1269188/iphone-sdk-adding-a-uiactivityindicatorview-to-a-uitableviewcell

class LoadingTableViewCell < UITableViewCell

  def configure(text = nil)
    if text.nil?
      text = "Loading..."
    end
    #cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:"NoReuse")
    self.textLabel.text = text

    spinner = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)

    # Spacer is a 1x1 transparent png
    spacer = UIImage.imageNamed("spacer")

    UIGraphicsBeginImageContext(spinner.frame.size)

    spacer.drawInRect(CGRectMake(0,0,spinner.frame.size.width,spinner.frame.size.height))
    resizedSpacer = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()
    self.imageView.image = resizedSpacer
    self.imageView.addSubview(spinner)
    spinner.startAnimating
  end
end

class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    tabBarController = UITabBarController.alloc.init
    mainController = YouOnMapController.alloc.init
    twoPointsController = TwoPointsController.alloc.init

    navController = UINavigationController.alloc.initWithRootViewController(twoPointsController)
    tabBarController.setViewControllers([mainController, navController], animated:false)

    # set icons
    icon = FAKFontAwesome.childIconWithSize(30)
    icon.addAttribute(NSForegroundColorAttributeName, value:UISettings.tabBarTitleColor)
    tab1_image = icon.imageWithSize(CGSizeMake(30, 30))

    icon = FAKFontAwesome.arrowsVIconWithSize(30)
    icon.addAttribute(NSForegroundColorAttributeName, value:UISettings.tabBarTitleColor)
    tab2_image = icon.imageWithSize(CGSizeMake(30, 30))

    # set titles
    tabBarController.tabBar.items[0].setFinishedSelectedImage(tab1_image, withFinishedUnselectedImage:tab1_image)
    tabBarController.tabBar.items[0].setTitle("You")
    tabBarController.tabBar.items[1].setFinishedSelectedImage(tab2_image, withFinishedUnselectedImage:tab2_image)
    tabBarController.tabBar.items[1].setTitle("Gain/Loss")

    #== Apply Global Styling
    UITabBar.appearance.setTintColor(UISettings.tintColor)

    @window.rootViewController = tabBarController
    @window.makeKeyAndVisible

    true
  end
end

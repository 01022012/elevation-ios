# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

require 'bundler'
Bundler.require
require 'bubble-wrap/core'
require 'bubble-wrap/location'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'elevation'
  app.version = '1.0'

  app.sdk_version = "7.1"
  app.short_version = app.version
  id = "com.codycaughlan.elevation"
  app.identifier = id
  app.frameworks += ['QuartzCore', 'CoreLocation', 'MapKit']
  app.prerendered_icon = false

  icons = Dir.glob("resources/Icon*.png")
  icons = icons.collect { |i| i.gsub("resources/", "") }
  app.icons = icons

  # Portrait only
  app.interface_orientations = [:portrait, :portrait_upside_down]

  if ENV['LOCAL']
    puts "** SIGNING FOR LOCAL DEVICE **"
    app.codesign_certificate = "iPhone Developer: Cody Caughlan (4M7ALMVEK9)"
    app.provisioning_profile = "./provisioning/development.mobileprovision"
  end

  app.pods do
    pod 'FontAwesomeKit', '2.1.7'
  end

end

Pod::Spec.new do |s|
  s.name         = 'GBAnalytics'
  s.version      = '2.11.1'
  s.summary      = 'Abstracts away different analytics networks and provides a unified simple interface.'
  s.homepage     = 'https://github.com/lmirosevic/GBAnalytics'
  s.license      = 'Apache License, Version 2.0'
  s.author       = { 'Luka Mirosevic' => 'luka@goonbee.com' }
  s.platform     = :ios, '6.0'
  s.source       = { git: 'https://github.com/lmirosevic/GBAnalytics.git', tag: s.version.to_s }
  s.source_files  = 'GBAnalytics/GBAnalytics.{h,m}', 'GBAnalytics/GBAnalyticsSettings.{h,m}', 'GBAnalytics/GBAnalyticsNetworks.h'
  s.public_header_files = 'GBAnalytics/GBAnalytics.h', 'GBAnalytics/GBAnalyticsSettings.h', 'GBAnalytics/GBAnalyticsNetworks.h'
  s.requires_arc = true

  s.frameworks = 'SystemConfiguration', 'CoreData'

  s.dependency 'Fabric', '~> 1.3'
  s.dependency 'Fabric/Crashlytics', '~> 1.3'
  s.dependency 'FlurrySDK', '~> 6.4'
  s.dependency 'GoogleAnalytics-iOS-SDK', '~> 3.0'
  s.dependency 'Tapstream', '~> 2.6'
  s.dependency 'Facebook-iOS-SDK', '~> 3.22.0'
  s.dependency 'Mixpanel', '~> 2.3'
  s.dependency 'Localytics', '~> 3.0'
  s.dependency 'Parse', '~> 1.6'
  s.dependency 'Amplitude-iOS', '~> 2.2'

  s.libraries = 'z', 'c++'
end

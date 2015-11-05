Pod::Spec.new do |s|
  s.name            = 'GBAnalytics'
  s.version         = '4.0.0'
  s.summary         = 'Abstracts away different analytics networks and provides a unified simple interface.'
  s.homepage        = 'https://github.com/lmirosevic/GBAnalytics'
  s.license         = 'Apache License, Version 2.0'
  s.author          = { 'Luka Mirosevic' => 'luka@goonbee.com' }
  s.source          = { git: 'https://github.com/lmirosevic/GBAnalytics.git', tag: s.version.to_s }
  s.platform        = :ios, '7.0'
  s.requires_arc    = true
  s.default_subspec = 'Core'

  # s.frameworks = 'SystemConfiguration', 'CoreData'

  s.subspec 'Core' do |ss|
    ss.source_files  = 'GBAnalytics/*.{h,m}'
    ss.public_header_files = 'GBAnalytics/*.h', 'GBAnalytics/Modules/*.h'
  end

  # Modules

  s.subspec 'GoogleAnalytics' do |ss|
    ss.source_files = "GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.{h,m}"
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.h'

    ss.dependency 'GoogleAnalytics', '~> 3.0'

    ss.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-DGBAnalyticsModule_GoogleAnalytics' }
  end

  s.subspec 'Flurry' do |ss|
    ss.source_files = "GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.{h,m}"
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.h'

    ss.dependency 'Flurry-iOS-SDK', '~> 7.3'

    ss.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-DGBAnalyticsModule_Flurry' }
  end

  s.subspec 'Crashlytics' do |ss|
    ss.source_files = "GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.{h,m}"
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.h'

    ss.dependency 'Fabric', '~> 1.5'

    ss.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-DGBAnalyticsModule_Crashlytics' }
    ss.dependency 'Crashlytics', '~> 3.3'
    ss.libraries = 'z', 'c++'
  end

  s.subspec 'Tapstream' do |ss|
    ss.source_files = "GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.{h,m}"
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.h'

    ss.dependency 'Tapstream', '~> 2.6'

    ss.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-DGBAnalyticsModule_Tapstream' }
  end

  s.subspec 'Facebook' do |ss|
    ss.source_files = "GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.{h,m}"
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.h'

    ss.dependency 'FBSDKCoreKit', '~> 4.6'

    ss.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-DGBAnalyticsModule_Facebook' }
  end

  s.subspec 'Mixpanel' do |ss|
    ss.source_files = "GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.{h,m}"
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.h'

    ss.dependency 'Mixpanel', '~> 2.3'

    ss.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-DGBAnalyticsModule_Mixpanel' }
  end

  s.subspec 'Parse' do |ss|
    ss.source_files = "GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.{h,m}"
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.h'

    ss.dependency 'Parse', '~> 1.6'

    ss.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-DGBAnalyticsModule_Parse' }
  end

  s.subspec 'Localytics' do |ss|
    ss.source_files = "GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.{h,m}"
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.h'

    ss.dependency 'Localytics', '~> 3.0'

    ss.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-DGBAnalyticsModule_Localytics' }
  end

  s.subspec 'Amplitude' do |ss|
    ss.source_files = "GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.{h,m}"
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_#{ss.name}.h'

    ss.dependency 'Amplitude-iOS', '~> 3.2'

    ss.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-DGBAnalyticsModule_Amplitude' }
  end
end

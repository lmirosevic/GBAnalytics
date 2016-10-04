Pod::Spec.new do |s|
  s.name            = 'GBAnalytics'
  s.version         = '4.4.0'
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
    ss.source_files = 'GBAnalytics/*.{h,m}'
    ss.public_header_files = 'GBAnalytics/*.h'
  end

  # Modules

  s.subspec 'Firebase' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_Firebase.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_Firebase.h'

    ss.dependency 'Firebase/Core', '~> 3.3'

    ss.dependency 'GBAnalytics/Core'
  end

  s.subspec 'GoogleAnalytics' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_GoogleAnalytics.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_GoogleAnalytics.h'

    ss.dependency 'GoogleAnalytics', '~> 3.0'

    ss.dependency 'GBAnalytics/Core'
  end

  s.subspec 'Flurry' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_Flurry.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_Flurry.h'

    ss.dependency 'Flurry-iOS-SDK/FlurrySDK', '~> 7.3'

    ss.dependency 'GBAnalytics/Core'
  end

  s.subspec 'Crashlytics' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_Crashlytics.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_Crashlytics.h'

    ss.dependency 'Crashlytics', '~> 3.3'
    ss.libraries = 'z', 'c++'

    ss.dependency 'GBAnalytics/Core'
  end

  s.subspec 'Answers' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_Answers.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_Answers.h'

    # This one is really just an alias for Crashlytics, which includes answers
    ss.dependency 'GBAnalytics/Crashlytics'

    ss.dependency 'GBAnalytics/Core'
  end

  s.subspec 'Tapstream' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_Tapstream.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_Tapstream.h'

    ss.dependency 'Tapstream', '~> 2.6'

    ss.dependency 'GBAnalytics/Core'
  end

  s.subspec 'Facebook' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_Facebook.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_Facebook.h'

    ss.dependency 'FBSDKCoreKit', '~> 4.6'

    ss.dependency 'GBAnalytics/Core'
  end

  s.subspec 'Mixpanel' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_Mixpanel.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_Mixpanel.h'

    ss.dependency 'Mixpanel', '~> 2.3'

    ss.dependency 'GBAnalytics/Core'
  end

  s.subspec 'Parse' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_Parse.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_Parse.h'

    ss.dependency 'Parse', '~> 1.6'

    ss.dependency 'GBAnalytics/Core'
  end

  s.subspec 'Localytics' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_Localytics.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_Localytics.h'

    ss.dependency 'Localytics', '~> 3.0'

    ss.dependency 'GBAnalytics/Core'
  end

  s.subspec 'Amplitude' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_Amplitude.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_Amplitude.h'

    ss.dependency 'Amplitude-iOS', '~> 3.2'

    ss.dependency 'GBAnalytics/Core'
  end

  s.subspec 'Intercom' do |ss|
    ss.source_files = 'GBAnalytics/Modules/GBAnalyticsModule_Intercom.{h,m}'
    ss.public_header_files = 'GBAnalytics/Modules/GBAnalyticsModule_Intercom.h'

    ss.ios.deployment_target = '8.0'
    ss.dependency 'Intercom', '~> 3.0'

    ss.dependency 'GBAnalytics/Core'
  end
end

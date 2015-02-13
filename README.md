# GBAnalytics ![Version](https://img.shields.io/cocoapods/v/GBAnalytics.svg?style=flat)&nbsp;![License](https://img.shields.io/badge/license-Apache_2-green.svg?style=flat)

Abstracts away different analytics networks and provides a unified simple interface.

Supported networks
------------

* Mixpanel
* Localytics
* Amplitude
* Parse
* Google Analytics
* Crashlytics
* Facebook
* Tapstream
* Flurry

Usage
------------

Connect to any number of networks you want in `application:didFinishLaunching:withOptions:`. This will automatically enable all their default stuff like session tracking, retention, etc.

```objective-c
// Connect Flurry
[GBAnalytics connectNetwork:GBAnalyticsNetworkFlurry withCredentials:@"FlurryAPIKey"];

// Connect Google Analytics
[GBAnalytics connectNetwork:GBAnalyticsNetworkGoogleAnalytics withCredentials:@"GoogleAnalyticsTrackingID"];

// Connect Mixpanel
[GBAnalytics connectNetwork:GBAnalyticsNetworkMixpanel withCredentials:@"MixpanelToken"];

// Connect Crashlytics
[GBAnalytics connectNetwork:GBAnalyticsNetworkCrashlytics withCredentials:@"CrashlyticsAPIKey"];
```

Track simple event:

```objective-c
[GBAnalytics trackEvent:@"Pressed play button"];
```

Track event with parameters:

```objective-c
[GBAnalytics trackEvent:@"Purchased in-app" withParameters:@{@"item": @"red sword"}];
```

You can still use all the more advanced features of the individual analytics networks libraries, GBAnalytics just helps you unify their setup and event tracking interfaces--the parts which would otherwise litter your code the most.

By default, GBAnalytics will not send any events for builds in the `Debug` configuration (unless you've modified your schemes, then this applies to all builds in the Simulator) to prevent littering your analytics dashboards with test data. If you DO want to send data when running on the Simulator, for example for testing integrations, then make sure you enable it:

```objective-c
GBAnalytics.force = YES;
```

Don't forget to import header, probably a good idea to put this in the precompiled header so it's accessible application wide:

```objective-c
#import <GBAnaytics/GBAnalytics.h>
```

Advanced usage
------------

What happens if you want to send some events to Mixpanel, and some other events to Flurry? Real world example: you want to send absolutely everything to Flurry and GA because they're free, but you only want to send the important stuff to Mixpanel because each event there costs you $$$. In this case you associate certain networks with a "route" and events posted on that route will be sent only to those networks:

```objective-c
// I'm creating a "common" route for the myriad of events which are interesting, but not interesting enough to pay Mixpanel for
[GBAnalytics[@"common"] routeToNetworks:GBAnalyticsNetworkFlurry, GBAnalyticsNetworkGoogleAnalytics, nil];

// And I'm creating a second route called "important" for the rare high-value stuff where I want to say use Mixpanel's people analytics (for instance)
[GBAnalytics[@"important"] routeToNetworks:GBAnalyticsNetworkMixpanel, nil];
```

Then you just send your events on the corresponding route:

```objective-c
// not so important event which happens all the time and I only want sent to Flurry and GA
[GBAnalytics[@"common"] trackEvent:@"Pressed play button"];

// very important event which I want sent to Mixpanel
[GBAnalytics[@"important"] trackEvent:@"Upgraded to pro version" withParameters:@{@"source": @"blue nag screen"}];
```

You might be wondering how come at first we didn't specify any route for our events... When you don't explictly specify a route (i.e. you use `[GBAnalytics trackEvent:@"My Event"]` instead of `[GBAnalytics[@"myRoute"] trackEvent:@"My Event"]`) you're just using a shorthand convenience for the default route (which happens to be defined as `kGBAnalyticsDefaultEventRoute`). The same applies to the `[GBAnalytics routeToNetworks:]` method. This is just syntactic sugar, the calls are identical.

Routes give you the convenience of being able to configure event destinations once in a centralised place, while still giving you the power to send each event to exactly the network(s) you want.

If you want to override which network the default route sends to, you can do so as well:

```objective-c
// The following two are equivalent:
[GBAnalytics routeToNetworks:GBAnalyticsNetworkFlurry, GBAnalyticsNetworkGoogleAnalytics, nil];
[GBAnalytics[@"kGBAnalyticsDefaultEventRoute"] routeToNetworks:GBAnalyticsNetworkFlurry, GBAnalyticsNetworkGoogleAnalytics, nil];
```

By default, the default route (`kGBAnalyticsDefaultEventRoute`) will send events to all connected networks, so if you just want to keep things simple and not worry about routes and send all events to all connected networks, you can ignore this API. If you do want to use custom routes (i.e. `route != kGBAnalyticsDefaultEventRoute`), the default behaviour is to not send any events until the networks to route to are explicitly specified using `routeToNetworks:`, in other words if you want to use `[GBAnalytics[@"someCustomRoute"] trackEvent:@"Beat the final level"]`, then make sure you call `[GBAnalytics[@"someCustomRoute"] routeToNetworks:...]` first or the events won't be sent anywhere.

Crashlytics Server-side Symbolication
------------

For Crashlytics to be able to symbolicate your crash reports, your app needs to send the dSYM file up to the Crashlytics servers. To do this automatically in post-build:

* Add a "Run Script" build phase to the target. This script assumes you have defined CRASHLYTICSAPIKEY and CRASHLYTICSBUILDSECRET inside your precompiled header file ("Prefix Header" build setting for target). You can also just put the keys directly into the script.

```sh
# Crashlytics dSYM upload

# get Crashlytics API Key and Build Secret from precompiled header and call the dSYM uploader with the key
CRASHLYTICSAPIKEY=$(grep CRASHLYTICSAPIKEY "${PROJECT_DIR}/${GCC_PREFIX_HEADER}" | awk '{print $3}' | grep -oEi "[^@^\"]+")
CRASHLYTICSBUILDSECRET=$(grep CRASHLYTICSAPIKEY "${PROJECT_DIR}/${GCC_PREFIX_HEADER}" | awk '{print $3}' | grep -oEi "[^@^\"]+")
"${SRCROOT}/Pods/CrashlyticsFramework/Crashlytics.framework/run" $CRASHLYTICSAPIKEY $CRASHLYTICSBUILDSECRET
```

Install
------------

Add to your project's Podfile:

`pod 'GBAnalytics'`

And run this in your project folder:

`pod install`

Lastly, if you use Crashlytics, add the build script to your project (see above).

Requirements & Details
------------

* Built using ARC
* Supports iOS 6 and above
* Does not use Apple's UDID.
* Does use Apple's IDFA so make sure you tick the correct boxes in iTunes Connect (aleays tick "this app uses the advertising identifier for attribution", if you should ads then also tick "this app shows ads", and if you use some of the attribution information from the analytics' networks' SDKs' to customise the user experience then tick that box too).

Copyright & License
------------

Copyright 2015 Goonbee

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

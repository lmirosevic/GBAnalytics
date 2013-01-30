GBAnalytics
============

Abstracts away different analytics networks and provides a unified simple interface

Usage
------------

First import header, probably a good idea to put this in the precompiled header:

```objective-c
#import "GBAnaytics.h"
```

Connect to any networks you want in `application:didFinishLaunching:withOptions:`

```objective-c
//Connect Flurry
[GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkFlurry withCredentials:@"FlurryAPIKey"];

//Connect Google Analytics
[GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkGoogleAnalytics withCredentials:@"GoogleAnalyticsTrackingID"];

//Connect Bugsense
[GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkBugSense withCredentials:@"BugsenseAPIKey"];
```

Track simple event (supports Flurry and Google Analytics):

```objective-c
_t(@"Pressed play button");
```

Track event with dictionary (supports Flurry):

```objective-c
_td(@"Purchased in-app", @{@"item": @"red sword"});
```

Supported networks
------------

* Flurry
* Google Analytics
* Bugsense

Dependencies
------------

Static libraries (Add dependency, link, -ObjC linker flag, header search path in superproject):

* GBToolbox

System Frameworks (link them in):

* CoreData
* SystemConfiguration
* libz.dylib

3rd party frameworks included (make sure project framework search path is correctly set, that framework is added to project as relative link, linked against in build phases of superproject):

* BugSense-iOS

Notes
------------

Bugsense related project settings for on-device symbolication:

* Strip Linked Symbols During Copy: NO
* Strip Linked Product: NO
* Deployment Postprocessing: NO
* Generate debug symbols: YES
* Other linker flags: -ObjC

Copyright & License
------------

Copyright 2013 Luka Mirosevic

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

 
 


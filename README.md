GBAnalytics
============

Abstracts away different analytics networks and provides a unified simple interface

Supported networks
------------

* Flurry
* Google Analytics
* Crashlytics
* Tapstream

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

//Connect Crashlytics
[GBAnalytics startSessionWithNetwork:GBAnalyticsNetworkCrashlytics withCredentials:@"CrashlyticsAPIKey"];
```

Track simple event (supports Flurry and Google Analytics):

```objective-c
_t(@"Pressed play button");
```

Track event with dictionary (supports Flurry):

```objective-c
_td(@"Purchased in-app", @{@"item": @"red sword"});
```

Dependencies
------------

Static libraries (Add dependency, link, -ObjC linker flag, header search path in superproject):

* [GBToolbox](https://github.com/lmirosevic/GBToolbox)

System Frameworks (link them in):

* CoreData
* SystemConfiguration
* libz.dylib

3rd party frameworks included (make sure project framework search path is correctly set, that framework is added to project as relative link, linked against in build phases of superproject):

* Crashlytics

Notes
------------

Crashlytics related project settings for automatic post-build dSYM uploads:

* Add "run script" build phase to target with appropriate path and API key. This script assumes you have created a macro called CRASHLYTICSAPIKEY inside your precompiled header file. You can also just put it straight in. Make sure path is correct!

```sh
#get Crashlytics API key from precompiled header and call the dSYM uploader with the key
CRASHLYTICSAPIKEY=$(grep CRASHLYTICSAPIKEY "${PROJECT_DIR}/${GCC_PREFIX_HEADER}" | awk '{print $3}' | grep -oEi "[^@^\"]+")
../../../Goonbee\ Modules/GBAnalytics/GBAnalytics/Crashlytics.framework/run $CRASHLYTICSAPIKEY
```

Copyright & License
------------

Copyright 2013 Luka Mirosevic

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/lmirosevic/gbanalytics/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

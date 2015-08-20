[![Build Status](https://travis-ci.org/Microsoft/ApplicationInsights-iOS.svg?branch=master)](https://travis-ci.org/Microsoft/ApplicationInsights-iOS)

# Application Insights for iOS (1.0-beta.6)

This is the repository of the iOS SDK for Application Insights. [Application Insights](http://azure.microsoft.com/en-us/services/application-insights/) is a service that allows developers to keep their applications available, performing, and succeeding. The SDK enables you to send telemetry of various kinds (events, traces, exceptions, etc.) to the Application Insights service where your data can be visualized in the Azure Portal.

The SDK runs on devices with iOS 6.0 or higher.

## Content

1. [Release Notes](#releasenotes)
2. [Breaking Changes](#breakingchanges)
3. [Requirements](#requirements)
4. [Setup](#setup)
5. [Advanced Setup](#advancedsetup)
6. [Developer Mode](#developermode)
7. [Basic Usage](#basicusage)
8. [Advanced Usage](#advancedusage)
9. [Automatic collection of life-cycle events](#autolifecycle)
10. [Crash Reporting](#crashreporting)
11. [Set Custom Server Endpoint](#additionalconfig)
12. [Documentation](#documentation)
13. [Contributing](#contributing)
14. [Contact](#contact)

<a name="releasenotes"></a>
## 1. Release Notes

* Important improvements to crash reports.
* We now filter some pageviews from standard view controllers in order to reduce noise and make pageviews more useful.
* Smaller refactorings and improvements.

See [here](https://github.com/Microsoft/ApplicationInsights-iOS/releases) for the release notes of previous versions.

<a name="breakingchanges"></a>
## 2. Breaking Changes
There haven't been any breaking changes since 1.0-beta.2. In case the API of the SDK changes, we will deprecate methods, etc. before removing them.

* **[1.0-beta.2]** ```MSAIAppInsights``` was the the central entry-point to use the Application Insights SDK. It has been renamed to  ```MSAIApplicationInsights```. 
* **[1.0-beta.2]** Setting the custom server URL now requires the complete URL to the server

<a id="requirements"></a>
## 3.  Requirements

The SDK runs on devices with iOS 6.0 or higher.

<a name="setup"></a>
## 4. Setup

We recommend integration of our binary into your Xcode project to setup Application Insights for your iOS app. For other ways to setup the SDK, see [Advanced Setup](#advancedsetup).

### 4.1 Obtain an Instrumation Key

Please see the "[Getting an Application Insights Instrumentation Key](https://github.com/Microsoft/ApplicationInsights-Home/wiki#getting-an-application-insights-instrumentation-key)" section of the wiki for more information on acquiring a key.

<a id="downloadsdk"></a>
### 4.2 Download the SDK

1. Download the latest [Application Insights for iOS](https://github.com/Microsoft/AppInsights-iOS/releases) framework which is provided as a zip-File.
2. Unzip the file and you will see a folder called `ApplicationInsights` .

### 4.3 Copy the SDK  into your projects directory in Finder

From our experience, 3rd-party libraries usually reside inside a subdirectory (let's call our subdirectory `Vendor`), so if you don't have your project organized with a subdirectory for libraries, now would be a great start for it. To continue our example,  create a folder called "Vendor" inside your project directory and move the unzipped `ApplicationInsights`-folder into it. 

<a id="setupxcode"></a>
### 4.4 Set up the SDK in Xcode

1. We recommend to use Xcode's group-feature to create a group for 3rd-party-libraries similar to the structure of our files on disk. For example,  similar to the file structure in 4.3 above, our projects have a group called `Vendor`.
2. Make sure the `Project Navigator` is visible (⌘+1)
3. Drag & drop `ApplicationInsights.framework` from your window in the `Finder` into your project in Xcode and move it to the desired location in the `Project Navigator` (e.g. into the group called `Vendor`)
4. A popup will appear. Select `Create groups for any added folders` and set the checkmark for your target. Then click `Finish`.
5. Open the `Info.plist` of your app target and add a new field of type *String*. Name it `MSAIInstrumentationKey` and set your Application Insights instrumentation key from 4.1 as its value.

<a id="modifycode"/>
### 4.5 Modify Code 

**Objective-C**

1. Open your `AppDelegate.m` file.
2. Add the following line at the top of the file below your own `import` statements:

	```objectivec
	@import ApplicationInsights;
	```

3. Search for the method `application:didFinishLaunchingWithOptions:`
4. Add the following lines to setup and start the Application Insights SDK:

	```objectivec
	[[MSAIApplicationInsights sharedInstance] setup];
	// Do some additional configuration if needed here
	//... more of your other setup code here ...
	[[MSAIApplicationInsights sharedInstance] start];
	```

	You can also use the following shortcuts:

	```objectivec
	[MSAIApplicationInsights setup];
	[MSAIApplicationInsights start];
	```

**Swift**

1. Open your `AppDelegate.swift` file.
2. Add the following line at the top of the file below your own import statements:
    
	```swift
	import ApplicationInsights
	```

3. Search for the method 
    
	```swift
	application(application: UIApplication, didFinishLaunchingWithOptions launchOptions:[NSObject: AnyObject]?) -> Bool`
	```

4. Add the following lines to setup and start the Application Insights SDK:
    
	```swift
	MSAIApplicationInsights.sharedInstance().setup();
	MSAIApplicationInsights.sharedInstance().start();
	```
    
	You can also use the following shortcuts:

	```swift
	MSAIApplicationInsights.setup()
	MSAIApplicationInsights.start()
	```

**Congratulation, now you're all set to use Application Insights! See [Basic Usage](#basicusage) on how to use Application Insights.**

<a id="advancedsetup"></a>
## 5. Advanced Setup

### 5.1 Set Instrumentation Key in Code

It is also possible to set the instrumentation key of your app in code. This will override the one you might have set in your `Info.plist`. To set it in code, MSAIApplicationInsights provides an overloaded constructor:

```objectivec
[MSAIApplicationInsights setupWithInstrumentationKey:@"{YOUR-INSTRUMENTATIONKEY}"];

//Do additional configuration

[MSAIApplicationInsights start];
```

<a id="linkmanually"/>
### 5.2 Linking System Frameworks manually

If you are working with an older project which doesn't support clang modules yet or you for some reason turned off the `Enable Modules (C and Objective-C` and `Link Frameworks Automatically` options in Xcode, you have to manually link some system frameworks:

1. Select your project in the `Project Navigator` (⌘+1).
2. Select your app target.
3. Select the tab `Build Phases`.
4. Expand `Link Binary With Libraries`.
5. Add the following system frameworks, if they are missing:
    - `UIKit`
    - `Foundation`
    - `SystemConfiguration`
    - `Security`
    - `libz`
    - `CoreTelephony`

Note that this also means that you can't use the `@import` syntax mentioned in the [Modify Code](#modify) section but have to stick to the old `#import <ApplicationInsights/ApplicationInsights.h>`.

### 5.3 Setup with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like ApplicationInsights in your projects. To learn how to setup CocoaPods for your project, visit the [official CocoaPods website](http://cocoapods.org/).

**[NOTE]**
When adding Application Insights to your podfile **without** specifying the version, `pod install` will throw an error because using a pre-release version of a pod has to be specified **explicitly**.
As soon as Application Insights 1.0 is available, the version doesn't have to be specified in your podfile anymore. 

**Podfile**

```ruby
platform :ios, '8.0'
pod "ApplicationInsights", '1.0-beta.4'
```

### 5.4 iOS 8 Extensions

The following points need to be considered to use the Application Insights SDK with iOS 8 Extensions:

1. Each extension is required to use the same values for version (`CFBundleShortVersionString`) and build number (`CFBundleVersion`) as the main app uses. (This is required only if you are using the same `MSAIInstrumentationKey` for your app and extensions).
2. You need to make sure the SDK setup code is only invoked **once**. Since there is no `applicationDidFinishLaunching:` equivalent and `viewDidLoad` can run multiple times, you need to use a setup like the following example:

```objectivec
@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic, assign) BOOL didSetupApplicationInsightsSDK;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.didSetupApplicationInsightsSDK) {
        [MSAIApplicationInsights setup];
        [MSAIApplicationInsights start];
        self.didSetupApplicationInsightsSDK = YES;
    }
}
```

### 5.4 WatchKit Extensions

WatchKit extensions don't use regular `UIViewControllers` but rather `WKInterfaceController` subclasses. These have a different lifecycle than you might be used to.
To make sure that the Application Insights SDK is only instantiated once in the WatchKit extension's lifecycle we recommend using a helper class similar to this:

```objectivec
@import Foundation;

@interface MSAIWatchSDKSetup : NSObject

+ (void)setupApplicationInsightsIfNeeded;

@end
```

```objectivec
#import "MSAIWatchSDKSetup.h"
#import "ApplicationInsights.h"

static BOOL applicationInsightsIsSetup = NO;

@implementation MSAIWatchSDKSetup

+ (void)setupApplicationInsightsIfNeeded {
  if (!applicationInsightsIsSetup) {
    [MSAIApplicationInsights setup];
    [MSAIApplicationInsights start];
    applicationInsightsIsSetup = YES;
  }
}

@end
```

Then, in each of your WKInterfaceControllers where you want to use the Application Insights SDK, you should do this:

```objectivec
#import "InterfaceController.h"
#import "ApplicationInsights.h"
#import "MSAIWatchSDKSetup.h"

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  [MSAIWatchSDKSetup setupApplicationInsightsIfNeeded];
}

- (void)willActivate {
  [super willActivate];
}

- (void)didDeactivate {
  [super didDeactivate];
}

@end
```

<a name="developermode"></a>
## 6. Developer Mode

###6.1 Batching of data

The **developer mode** is enabled automatically in case the debugger is attached or if the app is running in the simulator. This will  decrease the number of telemetry items sent in a batch (5 items) as well as the interval items when telemetry will be sent (3 seconds).

###6.2 Logging

We're all big fans of a clean debugging output without 3rd-party-SDKs messages piling up in the debugging view, right?!
That's why Application Insights keeps log messages to a minimum (like critical errors) unless the developer specifically enables debug logging before starting the SDK:

```objectivec
[MSAIApplicationInsights setup]; //setup the SDK
 
[[MSAIApplicationInsights sharedInstance] setDebugLogEnabled:YES]; //enable debug logging 

[MSAIApplicationInsights start]; //start using the SDK
```

This setting is ignored if the app is running in an app store environment, so the user's console won't be littered with our log messages.

<a id="basicusage"></a>
## 7. Basic Usage

**[NOTE]** The SDK is optimized to defer everything possible to a later time while making sure e.g. crashes on startup can also be caught and each module executes other code with a delay of some seconds. This ensures that `applicationDidFinishLaunching:` will process as fast as possible and the SDK will not block the startup sequence resulting in a possible kill by the watchdog process.

After you have set up the SDK as [described above](#setup), the ```MSAITelemetryManager```-instance is the central interface to track events, traces, metrics, page views or handled exceptions.

### 7.1 Objective-C

```objectivec
// Send an event with custom properties and measurements data
[MSAITelemetryManager trackEventWithName:@"Hello World event!"
                              properties:@{@"Test property 1":@"Some value",
                                           @"Test property 2":@"Some other value"}
                            measurements:@{@"Test measurement 1":@(4.8),
                                           @"Test measurement 2":@(15.16),
                                           @"Test measurement 3":@(23.42)}];

// Send a message
[MSAITelemetryManager trackTraceWithMessage:@"Test message"];

// Manually send pageviews (note: this will also be done automatically)
[MSAITelemetryManager trackPageView:@"MyViewController"
                           duration:300
                         properties:@{@"Test measurement 1":@(4.8)}];

// Send custom metrics
[MSAITelemetryManager trackMetricWithName:@"Test metric" value:42.2];

// Track handled exceptions
NSArray *zeroItemArray = [NSArray new];
@try {
	NSString *fooString = zeroItemArray[3];
} @catch(NSException *exception) {
	[MSAITelemetryManager trackException:exception];
}
```

### 7.2 Swift

```swift
// Send an event with custom properties and measuremnts data
MSAITelemetryManager.trackEventWithName("Hello World event!", 
								  properties:["Test property 1":"Some value",
											  "Test property 2":"Some other value"],
							    measurements:["Test measurement 1":4.8,
											  "Test measurement 2":15.16,
										      "Test measurement 3":23.42])

// Send a message
MSAITelemetryManager.trackTraceWithMessage("Test message")

// Manually send pageviews
MSAITelemetryManager.trackPageView("MyViewController",
								   duration:300,
							     properties:["Test measurement 1":4.8])

// Send a message
MSAITelemetryManager.trackMetricWithName("Test metric", value:42.2)
```

<a name="advancedusage"></a>
## 8. Advanced Usage

The SDK also allows for some more advanced usages.

### 8.1 Common Properties	

It is also possible to set so-called "common properties" that will then be automatically attached to all telemetry data items.

#### Objective-C

```objectivec
[MSAITelemetryManager setCommonProperties:@{@"custom info":@"some value"}];
```

#### Swift

```swift
MSAITelemetryManager.setCommonProperties(["custom info":"some value"])
```

<a name="autolifecycle"></a>
## 9. Automatic collection of lifecycle events

Automatic collection of lifecycle events is **enabled by default**. This means that Application Insights automatically tracks the appearance of a view controller and manages sessions for you.

### 9.1. Page views
The automatic tracking of viewcontroller appearance can be disabled between setup and start of the SDK.


```objectivec
[MSAIApplicationInsights setup]; //setup the SDK
 
[[MSAIApplicationInsights sharedInstance] setAutoPageViewTrackingDisabled:YES]; //disable the auto collection

[MSAIApplicationInsights start]; //start using the SDK
```

### 9.2. Sessions

By default, the Application Insights for iOS SDK starts a new session when the containing app is restarted (this means a 'cold start', i.e. when the app has not already been in memory prior to being launched) or when it has been in the background for more then 20 seconds. 

You can either change this timeframe:
``` objectivec
[MSAIApplicationInsights setAppBackgroundTimeBeforeSessionExpires:60];
```

Turn of automatic session management completely:
``` objectivec
[MSAIApplicationInsights setAutoSessionManagementDisabled:YES];
```

This then requires you to manage sessions manually:
``` objectivec
[MSAIApplicationInsights renewSessionWithId:@"4815162342"];
```

### 9.3. Users

Normally, a random anonymous ID is automatically generated for every user of your app by the SDK. Alternatively you can set your own user ID or other user attributes, which will then be attached to all telemetry events and crashes:
```objectivec
  [[MSAIApplicationInsights sharedInstance] setUserWithConfigurationBlock:^(MSAIUser *user) {
    user.userId = @"your_user_id";
    user.accountId = @"user@example.com";
  }];
```

<a name="crashreporting"></a>
## 10. Crash Reporting

The Application Insights SDK enables crash reporting **per default**. Crashes will be immediately sent to the server the next time the app is launched.
To provide you with the best crash reporting, we are using [PLCrashReporter]("https://github.com/plausiblelabs/plcrashreporter") in [Version 1.2 / Commit 273a7e7cd4b77485a584ac82e77b7c857558e2f9]("https://github.com/plausiblelabs/plcrashreporter/commit/273a7e7cd4b77485a584ac82e77b7c857558e2f9").

This feature can be disabled as follows:

```objectivec
[MSAIApplicationInsights setup]; //setup the SDK
 
[[MSAIApplicationInsights sharedInstance] setCrashManagerDisabled:YES]; //disable crash reporting

[MSAIApplicationInsights start]; //start using the SDK
```

<a name="additionalconfig"></a>
## 11.  Set Custom Server Endpoint

You can also configure a different server endpoint for the SDK if needed using a full URL

```objectivec
[MSAIApplicationInsights setup]; //setup the SDK

[[MSAIApplicationInsights sharedInstance] setServerURL:@"https://YOURDOMAIN/path/subpath"];
  
[MSAIApplicationInsights start]; //start using the SDK
```

<a id="documentation"></a>
## 12. Documentation

Our documentation can be found on [CocoaDocs](http://cocoadocs.org/docsets/ApplicationInsights/1.0-beta.4/).


<a id="contributing"></a>
## 13. Contributing

We're looking forward to your contributions via pull requests.

**Development environment**

* Mac running the latest version of OS X
* Get the latest Xcode from the Mac App Store
* [AppleDoc](https://github.com/tomaz/appledoc) 
* [Cocoapods](https://cocoapods.org/)

<a id="contact"></a>
## 14. Contact

If you have further questions or are running into trouble that cannot be resolved by any of the steps here, feel free to open a Github issue here or contact us at [AppInsights-iOS@microsoft.com](mailto:AppInsights-ios@microsoft.com)

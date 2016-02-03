[![Build Status](https://travis-ci.org/Microsoft/ApplicationInsights-iOS.svg?branch=master)](https://travis-ci.org/Microsoft/ApplicationInsights-iOS)

# Application Insights for iOS (1.0-beta.7)

This is the repository of the iOS SDK for Application Insights. [Application Insights](http://azure.microsoft.com/services/application-insights/) is a service that monitors the performance and usage of your published app. The SDK enables you to send telemetry of various kinds (events, traces, sessions etc.) to the Application Insights service where your data can be visualized in the Azure Portal.

You can use the [Application Insights for Mac](http://go.microsoft.com/fwlink/?linkid=533209&clcid=0x409) tool to integrate the Application Insights iOS SDK into your existing apps.
The SDK runs on devices with iOS 6.0 or higher. You'll need a subscription to [Microsoft Azure](https://azure.com). (It's free until you want to send quite a lot of telemetry.)

[Application Insights overview](https://azure.microsoft.com/documentation/articles/app-insights-overview/)

##Breaking Changes!

Version 1.0-beta.7 of the Application Insights for iOS SDK comes with two major changes:

Crash Reporting and the API to send handled exceptions have been removed from the SDK. In addition, the Application Insights for iOS SDK is now deprecated.

The reason for this is that [HockeyApp](http://hockeyapp.net/) is now our major offering for mobile and cross-plattform crash reporting, beta distribution and user feedback. We are focusing all our efforts on enhancing the HockeySDK and adding telemetry features to make HockeyApp the best platform to build awesome apps. We've launched [HockeyApp Preseason](http://hockeyapp.net/blog/2016/02/02/introducing-preseason.html) so you can try all the new bits yourself, including User Metrics.

We apologize for any inconvenience and please feel free to [contact us](http://support.hockeyapp.net/) at any time.

## Content

1. [Release Notes](#releasenotes)
2. [Requirements](#requirements)
3. [Setup](#setup)
4. [Advanced Setup](#advancedsetup)
5. [Developer Mode](#developermode)
6. [Basic Usage](#basicusage)
7. [Advanced Usage](#advancedusage)
8. [Automatic collection of life-cycle events](#autolifecycle)
9. [Set Custom Server Endpoint](#additionalconfig)
10. [Documentation](#documentation)
11. [Contributing](#contributing)
12. [Contact](#contact)

<a name="releasenotes"></a>
## 1. Release Notes

* Remove crash reporting. To add this feature to your app, we recommend to use [HockeyApp](http://hockeyapp.net/features/) which provides you with superior crash reporting, feedback, beta distribution and much more.
* Enable Bitcode. This was previously not possible as Bitcode-enabled apps are recompiled at unknown times on Apple's servers and make it very hard to get fully symbolicated and useful crash reports.
* Fixes an issue where pageview durations where incorrectly sent as days instead of as a string in the 'd:hh:mm:ss.fffffff' format. The relevant methods now take an `NSTimeInterval` parameter with the duration in seconds.

See [here](https://github.com/Microsoft/ApplicationInsights-iOS/releases) for the release notes of previous versions.

<a id="requirements"></a>
## 2.  Requirements

The SDK runs on devices with iOS 6.0 or higher.

<a name="setup"></a>
## 3. Setup

We recommend integration of our binary into your Xcode project to setup Application Insights for your iOS app. For other ways to setup the SDK, see [Advanced Setup](#advancedsetup).

You can use the [Application Insights for Mac](http://go.microsoft.com/fwlink/?linkid=533209&clcid=0x409) tool to integrate the SDK, which provides you with a step-by-step wizard for this process. If you want to integrate the SDK manually, you can do that by following this steps: 

### 3.1 Obtain an Instrumentation Key

To view your telemetry, you'll need an [Application Insights](https://azure.microsoft.com/documentation/articles/app-insights-overview/) resource in the [Microsoft Azure Portal](https://portal.azure.com). You can either:

* [Create a new resource](https://azure.microsoft.com/documentation/articles/app-insights-create-new-resource/); or
* If your app uses a web service, use the same resource you set up to monitor that. See setup [for ASP.NET](https://azure.microsoft.com/documentation/articles/app-insights-asp-net/) or [for J2EE](https://azure.microsoft.com/documentation/articles/app-insights-java-get-started/).

Open your resource and open the Essentials drop-down. Shortly, you'll need to copy the Instrumentation Key.

<a id="downloadsdk"></a>
### 3.2 Download the SDK

1. Download the latest [Application Insights for iOS](https://github.com/Microsoft/ApplicationInsights-iOS/releases) framework which is provided as a zip-File.
2. Unzip the file and you will see a folder called `ApplicationInsights` .

### 3.3 Copy the SDK  into your projects directory in Finder

From our experience, 3rd-party libraries usually reside inside a subdirectory (let's call our subdirectory `Vendor`), so if you don't have your project organized with a subdirectory for libraries, now would be a great start for it. To continue our example,  create a folder called "Vendor" inside your project directory and move the unzipped `ApplicationInsights`-folder into it. 

<a id="setupxcode"></a>
### 3.4 Set up the SDK in Xcode

1. We recommend to use Xcode's group-feature to create a group for 3rd-party-libraries sixmilar to the structure of our files on disk. For example,  similar to the file structure in 4.3 above, our projects have a group called `Vendor`.
2. Make sure the `Project Navigator` is visible (⌘+1)
3. Drag & drop `ApplicationInsights.framework` from your window in the `Finder` into your project in Xcode and move it to the desired location in the `Project Navigator` (e.g. into the group called `Vendor`)
4. A popup will appear. Select `Create groups for any added folders` and set the checkmark for your target. Then click `Finish`.
5. Open the `Info.plist` of your app target and add a new field of type *String*. Name it `MSAIInstrumentationKey` and set your Application Insights instrumentation key from 4.1 as its value.

<a id="modifycode"/>
### 3.5 Modify Code 

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
## 4. Advanced Setup

### 4.1 Set Instrumentation Key in Code

It is also possible to set the instrumentation key of your app in code. This will override the one you might have set in your `Info.plist`. To set it in code, MSAIApplicationInsights provides an overloaded constructor:

```objectivec
[MSAIApplicationInsights setupWithInstrumentationKey:@"{YOUR-INSTRUMENTATIONKEY}"];

//Do additional configuration

[MSAIApplicationInsights start];
```

<a id="linkmanually"/>
### 4.2 Linking System Frameworks manually

If you are working with an older project which doesn't support clang modules yet or you for some reason turned off the `Enable Modules (C and Objective-C` and `Link Frameworks Automatically` options in Xcode, you have to manually link some system frameworks:

1. Select your project in the `Project Navigator` (⌘+1).
2. Select your app target.
3. Select the tab `Build Phases`.
4. Expand `Link Binary With Libraries`.
5. Add the following system frameworks, if they are missing:
    - `CoreTelephony`
    - `Foundation`
    - `Security`
    - `SystemConfiguration`
    - `UIKit`
    - `libz`

Note that this also means that you can't use the `@import` syntax mentioned in the [Modify Code](#modify) section but have to stick to the old `#import <ApplicationInsights/ApplicationInsights.h>`.

### 4.3 Setup with CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like ApplicationInsights in your projects. To learn how to setup CocoaPods for your project, visit the [official CocoaPods website](https://cocoapods.org/).

**[NOTE]**
When adding Application Insights to your podfile **without** specifying the version, `pod install` will throw an error because using a pre-release version of a pod has to be specified **explicitly**.
As soon as Application Insights 1.0 is available, the version doesn't have to be specified in your podfile anymore. 

**Podfile**

```ruby
platform :ios, '8.0'
pod "ApplicationInsights", '1.0-beta.4'
```

### 4.4 iOS 8 Extensions

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

### 4.5 WatchKit Extensions

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
## 5. Developer Mode

###5.1 Batching of data

The **developer mode** is enabled automatically in case the debugger is attached or if the app is running in the simulator. This will  decrease the number of telemetry items sent in a batch (5 items) as well as the interval items when telemetry will be sent (3 seconds).

###5.2 Logging

We're all big fans of a clean debugging output without 3rd-party-SDKs messages piling up in the debugging view, right?!
That's why Application Insights keeps log messages to a minimum (like critical errors) unless the developer specifically enables debug logging before starting the SDK:

```objectivec
[MSAIApplicationInsights setup]; //setup the SDK
 
[[MSAIApplicationInsights sharedInstance] setDebugLogEnabled:YES]; //enable debug logging 

[MSAIApplicationInsights start]; //start using the SDK
```

This setting is ignored if the app is running in an app store environment, so the user's console won't be littered with our log messages.

<a id="basicusage"></a>
## 6. Basic Usage

**[NOTE]** The SDK is optimized to defer everything possible to a later time while making sure each module executes other code with a delay of some seconds. This ensures that `applicationDidFinishLaunching:` will process as fast as possible and the SDK will not block the startup sequence resulting in a possible kill by the watchdog process.

After you have set up the SDK as [described above](#setup), the ```MSAITelemetryManager```-instance is the central interface to track events, traces, metrics, page views or handled exceptions.

For an overview of how to use the API and view the results in the Application Insights resource, see [API Overview](https://azure.microsoft.com/documentation/articles/app-insights-api-custom-events-metrics/). The examples are in Java, but the principles are the same.

### 6.1 Objective-C

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

```

### 6.2 Swift

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

### View your data in the portal

In the [Azure portal](https://portal.azure.com), open the application resource that you created to get your instrumentation key. You'll see charts showing counts of page views and sessions. To see more:

* Click any chart to see more detail. You can [create your own metric pages, set alerts, and filter and segment your data](https://azure.microsoft.com/documentation/articles/app-insights-metrics-explorer/).
* Click [Search](https://azure.microsoft.com/documentation/articles/app-insights-diagnostic-search/) to see individual trackEvent, trackTrace, trackException and trackPageView messages.

<a name="advancedusage"></a>
## 7. Advanced Usage

The SDK also allows for some more advanced usages.

### 7.1 Common Properties 

It is also possible to set so-called "common properties" that will then be automatically attached to all telemetry data items.

#### Objective-C

```objectivec
[MSAITelemetryManager setCommonProperties:@{@"custom info":@"some value"}];
```

#### Swift

```swift
MSAITelemetryManager.setCommonProperties(["custom info":"some value"])
```

#### Filter your views by properties

Use the properties to [segment and filter metric charts](https://azure.microsoft.com/documentation/articles/app-insights-metrics-explorer/#segment-your-data) and [filter searches](https://azure.microsoft.com/documentation/articles/app-insights-diagnostic-search/#filter-on-property-values).

<a name="autolifecycle"></a>
## 8. Automatic collection of lifecycle events

Automatic collection of lifecycle events is **enabled by default**. This means that Application Insights automatically tracks the appearance of a view controller and manages sessions for you.

### 8.1. Page views
The automatic tracking of viewcontroller appearance can be disabled between setup and start of the SDK.

```objectivec
[MSAIApplicationInsights setup]; //setup the SDK
 
[[MSAIApplicationInsights sharedInstance] setAutoPageViewTrackingDisabled:YES]; //disable the auto collection

[MSAIApplicationInsights start]; //start using the SDK
```

### 8.2. Sessions

By default, the Application Insights for iOS SDK starts a new session when the containing app is restarted (this means a 'cold start', i.e. when the app has not already been in memory prior to being launched) or when it has been in the background for more than 20 seconds. 

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

### 8.3. Users

Normally, a random anonymous ID is automatically generated for every user of your app by the SDK. Alternatively you can set your own user ID or other user attributes, which will then be attached to all telemetry events:
```objectivec
  [[MSAIApplicationInsights sharedInstance] setUserWithConfigurationBlock:^(MSAIUser *user) {
    user.userId = @"your_user_id";
    user.accountId = @"user@example.com";
  }];
```

<a name="additionalconfig"></a>
## 9.  Set Custom Server Endpoint

You can also configure a different server endpoint for the SDK if needed using a full URL

```objectivec
[MSAIApplicationInsights setup]; //setup the SDK

[[MSAIApplicationInsights sharedInstance] setServerURL:@"https://YOURDOMAIN/path/subpath"];
  
[MSAIApplicationInsights start]; //start using the SDK
```

<a id="documentation"></a>
## 10. Documentation

Our documentation can be found on [CocoaDocs](http://cocoadocs.org/docsets/ApplicationInsights/1.0-beta.4/).


<a id="contributing"></a>
## 11. Contributing

We're looking forward to your contributions via pull requests.

**Development environment**

* Mac running the latest version of OS X
* Get the latest Xcode from the Mac App Store
* [AppleDoc](https://github.com/tomaz/appledoc) 
* [Cocoapods](https://cocoapods.org/)

<a id="contact"></a>
## 12. Contact

If you have further questions or are running into trouble that cannot be resolved by any of the steps here, feel free to open a GitHub issue here or contact us at [support@hockeyapp.net](mailto:support@hockeyapp.net)

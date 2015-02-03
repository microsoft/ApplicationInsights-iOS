## AppInsights SDK iOS (1.0-a.1)

## Introduction

This article describes how to integrate AppInsights into your iOS apps. The SDK  allows to send application metrics (events, traces, metrics, and pageviews) to the server. 

This document contains the following sections:

- [Requirements](#requirements)
- [Download & Extract](#download)
- [Set up Xcode](#xcode) 
- [Modify Code](#modify)
- [iOS 8 Extensions](#extension)
- [Additional Options](#options)

<a id="requirements"></a> 
## Requirements

The SDK runs on devices with iOS 6.0 or higher.

<a id="download"></a> 
## Download & Extract

1. Download the latest [AppInsights SDK for iOS](https://rink.hockeyapp.net/apps/19e2b445f2769757bd4d384e56f1fc3b) framework.

2. Unzip the file. A new folder `AppInsights` is created.

3. Move the folder into your project directory. We usually put 3rd-party code into a subdirectory named `Vendor`, so we move the directory into it.

<a id="xcode"></a> 
## Set up Xcode

1. Drag & drop `AppInsights.framework` from your project directory to your Xcode project.

2. Similar to above, our projects have a group `Vendor`, so we drop it there.

3. Select `Create groups for any added folders` and set the checkmark for your target. Then click `Finish`.

4. Select your project in the `Project Navigator` (⌘+1).

5. Select your app target.

6. Select the tab `Build Phases`.

7. Expand `Link Binary With Libraries`.

8. Add the following system frameworks, if they are missing:
- `AssetsLibrary`
- `Foundation`
- `MobileCoreServices`
- `Security`
- `SystemConfiguration`
- `UIKit`

<a id="modify"></a> 
## Modify Code 

### Objective-C

1. Open your `AppDelegate.m` file.

2. Add the following line at the top of the file below your own #import statements:

		#import <AppInsights/AppInsights.h>

3. Search for the method `application:didFinishLaunchingWithOptions:`

4. Add the following lines (Replace `INSTRUMENTATION_KEY` with the app instrumentation key of your app):

		[[MSAITelemetryManager sharedMSAIManager] configureWithInstrumentationKey:@"INSTRUMENTATION_KEY"];
		[[MSAITelemetryManager sharedMSAIManager] startManager];

5. Send some data to the server:

		// Send an event with custom properties and measuremnts data
		[MSAIMetricsManager trackEventWithName:@"Hello World event!"
									 properties:@{@"Test property 1":@"Some value",
												  @"Test property 2":@"Some other value"}
									mesurements:@{@"Test measurement 1":@(4.8),
												  @"Test measurement 2":@(15.16),
		                                         @"Test measurement 3":@(23.42)}];

		// Send a message
		[MSAIMetricsManager trackTraceWithMessage:@"Test message"];

		// Manually send pageviews
		[MSAIMetricsManager trackPageView:@"MyViewController"
								  duration:300
								properties:@{@"Test measurement 1":@(4.8)}];

		// Send a message
		[MSAIMetricsManager trackMetricWithName:@"Test metric" 
										   value:42.2];

*Note:* The SDK is optimized to defer everything possible to a later time while making sure e.g. crashes on startup can also be caught and each module executes other code with a delay some seconds. This ensures that applicationDidFinishLaunching will process as fast as possible and the SDK will not block the startup sequence resulting in a possible kill by the watchdog process.

### Swift

1. Open your `AppDelegate.swift` file.

2. Add the following line at the top of the file below your own #import statements:

		#import AppInsights

3. Search for the method `application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool`


4. Add the following lines (Replace `INSTRUMENTATION_KEY` with the app instrumentation key of your app):

		MSAITelemetryManager.sharedMSAIManager().configureWithInstrumentationKey("INSTRUMENTATION_KEY");
        MSAITelemetryManager.sharedMSAIManager().startManager();

5. Send some data to the server:

		// Send an event with custom properties and measuremnts data
		MSAIMetricsManager.trackEventWithName(name:"Hello World event!", 
										 properties:@{"Test property 1":"Some value",
												      "Test property 2":"Some other value"},
										mesurements:@{"Test measurement 1":@(4.8),
												      "Test measurement 2":@(15.16),
 											          "Test measurement 3":@(23.42)});

		// Send a message
		MSAIMetricsManager.trackTraceWithMessage(message:"Test message");

		// Manually send pageviews
		MSAIMetricsManager.trackPageView(pageView:"MyViewController",
										  duration:300,
										properties:@{"Test measurement 1":@(4.8)});

		// Send a message
		MSAIMetricsManager.trackMetricWithName(name:"Test metric",
											   value:42.2);

<a id="extensions"></a>
## iOS 8 Extensions

The following points need to be considered to use AppInsights SDK iOS with iOS 8 Extensions:

1. Each extension is required to use the same values for version (`CFBundleShortVersionString`) and build number (`CFBundleVersion`) as the main app uses. (This is required only if you are using the same INSTRUMENTATION_KEY for your app and extensions).
2. You need to make sure the SDK setup code is only invoked once. Since there is no `applicationDidFinishLaunching:` equivalent and `viewDidLoad` can run multiple times, you need to use a setup like the following example:

        @interface TodayViewController () <NCWidgetProviding>

        @property (nonatomic, assign) BOOL didSetupAppInsightsSDK;

        @end

        @implementation TodayViewController

        - (void)viewDidLoad {
          [super viewDidLoad];
          if (!self.didSetupAppInsightsSDK) {
            [[MSAITelemetryManager sharedMSAIManager] configureWithInstrumentationKey:@"INSTRUMENTATION_KEY"];
		[[MSAITelemetryManager sharedMSAIManager] startManager];
            self.didSetupAppInsightsSDK = YES;
          }
        }
 
<a id="options"></a> 
## Additional Options

### Set up with xcconfig

Instead of manually adding the missing frameworks, you can also use our bundled xcconfig file.

1. Select your project in the `Project Navigator` (⌘+1).

2. Select your project.

3. Select the tab `Info`.

4. Expand `Configurations`.

5. Select `AppInsights.xcconfig` for all your configurations (if you don't already use a `.xcconfig` file)

**Note:** You can also add the required frameworks manually to your targets `Build Phases` and continue with step `7.` instead.

6. If you are already using a `.xcconfig` file, simply add the following line to it

`#include "../Vendor/AppInsights/Support/AppInsights.xcconfig"`

(Adjust the path depending where the `Project.xcconfig` file is located related to the Xcode project package)

**Important note:** Check if you overwrite any of the build settings and add a missing `$(inherited)` entry on the projects build settings level, so the `AppInsights.xcconfig` settings will be passed through successfully.

7. If you are getting build warnings, then the `.xcconfig` setting wasn't included successfully or its settings in `Other Linker Flags` get ignored because `$(inherited)` is missing on project or target level. Either add `$(inherited)` or link the following frameworks manually in `Link Binary With Libraries` under `Build Phases`:
- `AssetsLibrary`
- `Foundation`
- `MobileCoreServices`
- `Security`
- `SystemConfiguration`
- `UIKit`

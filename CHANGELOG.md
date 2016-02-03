## 1.0-beta.7 (3/2/2016)

**Crash Reporting and the API to send handled exceptions have been removed from the SDK. In addition, the Application Insights for iOS SDK is now deprecated.**

The reason for this is that [HockeyApp](http://hockeyapp.net/) is now our major offering for mobile and cross-plattform crash reporting, beta distribution and user feedback. We are focusing all our efforts on enhancing the HockeySDK and adding telemetry features to make HockeyApp the best platform to build awesome apps. We've launched [HockeyApp Preseason](http://hockeyapp.net/blog/2016/02/02/introducing-preseason.html) so you can try all the new bits yourself, including User Metrics.

* Remove crash reporting. To add this feature to your app, we recommend to use [HockeyApp](http://hockeyapp.net/features/) which provides you with superior crash reporting, feedback, beta distribution and much more.
* Enable Bitcode. This was previously not possible as Bitcode-enabled apps are recompiled at unknown times on Apple's servers and make it very hard to get fully symbolicated and useful crash reports.
* Fixes an issue where pageview durations where incorrectly sent as days instead of as a string in the 'd:hh:mm:ss.fffffff' format. The relevant methods now take an `NSTimeInterval` parameter with the duration in seconds.

## 1.0-beta.6 (7/8/2015)

* Add CHANGELOG.md
* Update contract files to match newest schema  version
* Removed previously deprecated methods to set a custom userID
* Minor bugfixes and improvements

## 1.0-beta.5 (6/7/2014)

* Important improvements to crash reports.
* We now filter some pageviews from standard view controllers in order to reduce noise and make pageviews more useful.
* Smaller refactorings and improvements.

## 1.0-beta.4 (23/6/2015)

* Allow for easier integration in most projects using the `@import ApplicationInsights;` syntax. This makes manual linking of system frameworks unnecessary!
* Add feature to set common properties that will apply to all telemetry data items.

    ```objectivec
    [MSAITelemetryManager setCommonProperties:@{@"custom info":@"some value"}];
    ```

* Allow for further customization of user context fields.
Note that this means that the old way of setting the user ID, `setUserId:`, is now deprecated!

    ```objectivec
      [[MSAIApplicationInsights sharedInstance] setUserWithConfigurationBlock:^(MSAIUser *user) {
        user.userId = @"your_user_id";
        user.accountId = @"user@example.com";
      }];
    ```

* Add support for unhandled C++ exceptions
* Switch to sending data in JSON Stream format to improve compatibility with different server backends.
* Improve crash reports by sending additional exception information.
* Add instructions to Readme about how to setup the SDK with WatchKit extensions.
* Add logging incase the developer tries to send objects that are not NSJSONSerialization compatible.
* Fix issues with the backwars compatiblity of the nullability annotation.
* Various other small improvements and fixes.

## 1.0-beta.3 (8/5/2015)

* Add new API to be able to manually set session and user IDs.

    ``` objectivec
    [MSAIApplicationInsights setUserId:@"your_user_id"];
    [MSAIApplicationInsights renewSessionWithId:@"4815162342"];
    ```

* Allow to specify the amount of time that an app has to have been in the background before a new session is triggered.

    ``` objectivec
    [MSAIApplicationInsights setAppBackgroundTimeBeforeSessionExpires:60];
    ```

* Make our sending-retry policy more robust and only delete data on unrecoverable HTTP status codes.
* Trigger saving of queued-up date when the app goes to the background since then there is a high probability it might be removed from memory by the OS.
* Add our Xcode docset part of the downloaded archive.
* Several small fixes, cleanups and optimizations under the hood.

## 1.0-beta.2 (28/4/2015)

* The size of the devices screen is now reported in physical pixels
* Renamed umbrella-class and product to **ApplicationInsights**
* Cleaned up code
* Removed previously deprecated methods and classes
* The order of stackframes is now reversed to appear in the portal correctly
* Developer Mode for more ease during development/debugging
* Includes Nullability warnings (learn more readin ([Apple's own blogpost]("https://developer.apple.com/swift/blog/?id=25") about this)
* Add gzip-support to dramatically decrease data volume used to send data to the server
* _Developer mode_ for ease of debugging
* Setting a custom server now requires the complete URL to the server (e.g. https://yourdomin/something/tracking/)

### Breaking Changes

Starting with the first 1.0 stable release, we will start deprecating API instead of breaking old ones.

* **[1.0-beta.2]** ```MSAIAppInsights``` was the the central entry-point to use the Application Insights SDK. It has been renamed to  ```MSAIApplicationInsights```. 
* **[1.0-beta.2]** Setting the custom server URL now requires the complete URL to the server

## 1.0-beta.1 (10/4/2015)

- Add a mechanism to try and save not-yet-persisted events if the containing app crashes. The events will then be sent on next app start.
- Simplify the way session IDs are handled in the background and make it more consistent.
- Fix spelling in different places.
    * Please note: `trackEventWithName:properties:mesurements:` is now deprecated and replaced by `trackEventWithName:properties:measurements:`
- Improve error logging when errors occur during sending. (Enable debug logging to see these)
- Update the way we save data in the keychain for maximum compatibility.
- Extend guides to add `Security` system framework.

## 1.0-alpha.3 (26/3/2015)

- Performance improvements
- Expose configuarations:
    * Set serverURL programmatically
    * Automatic page view tracking
    * Set instrumentation key programmatically
- Bug fixes
    * Use session id of previous session for crashes
    * Session context for page views
    * Prevent SDK from crashing if too many events are tracked
- Add user context to payload
- Breaking change: Rename MSAIMetricsManager to MSAITelemetryManager

## 1.0-alpha.2 (25/2/2015)

This pre-release version of the AppInsights iOS SDK adds crash reporting as a feature, as well as lots of improvements and enhancements around our abilities to send metrics data.

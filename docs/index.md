## Introduction

This project provides an iOS SDK for Application Insights. [Application Insights](http://azure.microsoft.com/en-us/services/application-insights/) is a service that allows developers to keep their applications available, performing, and succeeding. This module allows you to send telemetry of various kinds (events, traces, exceptions, etc.) to the Application Insights service where your data can be visualized in the Azure Portal.

The following features are currently supported:

1. **Send telemetry data:** The SDK allows you to send telemetry of various kinds (event, trace, measurement, etc.) to the Application Insights service where they can be visualized in the Azure Portal.

2. **Collect crash reports:** If you app crashes, a crash log with the same format as from the Apple Crash Reporter is written to the device's storage. If the user starts the app again, he is asked to submit the crash report to Application Insights. This works for both beta and live apps, i.e. those submitted to the App Store!

The main SDK class is `MSAIAppInsights`. It initializes all modules and provides access to them, so they can be further adjusted if required. Additionally all modules provide their own protocols.

## Howto

Please have a look at our [Readme](Readme)

## Repository

We're on [Github](https://github.com/Microsoft/ApplicationInsights-iOS)

## Contact

If you have further questions or are running into trouble that cannot be resolved by any of the steps here, feel free to contact us at [AppInsights-iOS@microsoft.com](mailto:AppInsights-ios@microsoft.com)

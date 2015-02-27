## Introduction

AppInsights-iOS implements support for using HockeyApp in your iOS applications.

The following features are currently supported:

1. **Send telemetry data:** The SDK allows you to send telemetry of various kinds (event, trace, measurement, etc.) to the Application Insights service where they can be visualized in the Azure Portal.

2. **Collect crash reports:** If you app crashes, a crash log with the same format as from the Apple Crash Reporter is written to the device's storage. If the user starts the app again, he is asked to submit the crash report to Application Insights. This works for both beta and live apps, i.e. those submitted to the App Store!

The main SDK class is `MSAIAppInsights`. It initializes all modules and provides access to them, so they can be further adjusted if required. Additionally all modules provide their own protocols.

## Prerequisites

1. Before you integrate Application Insights into your own app, you should add the app in the Azure Portal if you haven't already. Read [this how-to](http://azure.microsoft.com/en-us/documentation/articles/app-insights-get-started/) about generel information on how to get started with Application Insights.
2. We also assume that you already have a project in Xcode and that this project is opened in Xcode 6.
3. The SDK supports iOS 6.0 or newer.

## Release Notes

- [Changelog](Changelog)

## Guides

- [Installation & Setup](Guide-Installation-Setup)

## HowTos

- [How to do app versioning](HowTo-App-Versioning)
- [How to upload symbols for crash reporting](HowTo-Upload-Symbols)

## Troubleshooting

- [Crash Reporting is not working](Troubleshooting-Crash-Reporting-Not-Working)
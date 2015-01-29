/*
 * This file is only used by the binary framework target when building
 * and creating the crash reporting only framework
 *
 * Attention: Do not include this into your projects yourself!
 */
 
#ifndef AppInsights_AppInsightsFeatureConfig_h
#define APPINSIGHTS_APPINSIGHTSFeatureConfig_h


/**
 * If true, include support for handling crash reports
 *
 * _Default_: Enabled
 */
#ifndef APPINSIGHTS_FEATURE_CRASH_REPORTER
#    define APPINSIGHTS_FEATURE_CRASH_REPORTER 1
#endif /* APPINSIGHTS_FEATURE_CRASH_REPORTER */


/**
 * If true, include support for managing user feedback
 *
 * _Default_: Enabled
 */
#ifndef APPINSIGHTS_FEATURE_FEEDBACK
#    define APPINSIGHTS_FEATURE_FEEDBACK 0
#endif /* APPINSIGHTS_FEATURE_FEEDBACK */


/**
 * If true, include support for informing the user about new updates pending in the App Store
 *
 * _Default_: Enabled
 */
#ifndef APPINSIGHTS_FEATURE_STORE_UPDATES
#    define APPINSIGHTS_FEATURE_STORE_UPDATES 0
#endif /* APPINSIGHTS_FEATURE_STORE_UPDATES */


/**
 * If true, include support for authentication installations for Ad-Hoc and Enterprise builds
 *
 * _Default_: Enabled
 */
#ifndef APPINSIGHTS_FEATURE_AUTHENTICATOR
#    define APPINSIGHTS_FEATURE_AUTHENTICATOR 0
#endif /* APPINSIGHTS_FEATURE_AUTHENTICATOR */


/**
 * If true, include support for handling in-app udpates for Ad-Hoc and Enterprise builds
 *
 * _Default_: Enabled
 */
#ifndef APPINSIGHTS_FEATURE_UPDATES
#    define APPINSIGHTS_FEATURE_UPDATES 0
#endif /* APPINSIGHTS_FEATURE_UPDATES */


#endif /* AppInsights_AppInsightsFeatureConfig_h */

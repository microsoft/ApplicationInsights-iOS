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
#    define APPINSIGHTS_FEATURE_CRASH_REPORTER 0
#endif /* APPINSIGHTS_FEATURE_CRASH_REPORTER */


/**
 * If true, include support for sending metrics data
 *
 * _Default_: Enabled
 */
#ifndef MSAI_FEATURE_METRICS
#    define MSAI_FEATURE_METRICS 1
#endif /* MSAI_FEATURE_METRICS */


#endif /* AppInsights_AppInsightsFeatureConfig_h */

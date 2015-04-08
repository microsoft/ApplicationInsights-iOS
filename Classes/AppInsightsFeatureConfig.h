#ifndef MSAI_FeatureConfig_h
#define MSAI_FeatureConfig_h


/**
 * If true, include support for handling crash reports
 *
 * _Default_: Disabled
 */
#ifndef MSAI_FEATURE_CRASH_REPORTER
#    define MSAI_FEATURE_CRASH_REPORTER 1
#endif /* MSAI_FEATURE_CRASH_REPORTER */


/**
 * If true, include support for gathering telemetry
 *
 * _Default_: Enabled
 */
#ifndef MSAI_FEATURE_TELEMETRY
#    define MSAI_FEATURE_TELEMETRY 1
#endif /* MSAI_FEATURE_TELEMETRY */


#endif /* MSAI_FeatureConfig_h */

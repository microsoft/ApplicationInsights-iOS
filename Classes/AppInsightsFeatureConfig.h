#ifndef MSAI_FeatureConfig_h
#define MSAI_FeatureConfig_h


/**
 * If true, include support for handling crash reports
 *
 * _Default_: Disabled
 */
#ifndef MSAI_FEATURE_CRASH_REPORTER
#    define MSAI_FEATURE_CRASH_REPORTER 0
#endif /* MSAI_FEATURE_CRASH_REPORTER */


/**
 * If true, include support for gathering metrics
 *
 * _Default_: Enabled
 */
#ifndef MSAI_FEATURE_METRICS
#    define MSAI_FEATURE_METRICS 1
#endif /* MSAI_FEATURE_METRICS */


#endif /* MSAI_FeatureConfig_h */

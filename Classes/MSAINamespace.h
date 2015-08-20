/*
 * For external library integrators:
 *
 * Set this value to any valid C symbol prefix. This will automatically
 * prepend the given prefix to all external symbols in the library.
 *
 * This may be used to avoid symbol conflicts between multiple libraries
 * that may both incorporate PLCrashReporter.
 */
#define MSAI_SDK_PREFIX BIT


// We need two extra layers of indirection to make CPP substitute
// the MSAI_SDK_PREFIX define.
#define RENAME_impl2(prefix, symbol) prefix ## symbol
#define RENAME_impl(prefix, symbol) RENAME_impl2(prefix, symbol)
#define RENAME(symbol) RENAME_impl(MSAI_SDK_PREFIX, symbol)


/*
 * Rewrite all ObjC/C symbols.
 */
#ifdef MSAI_SDK_PREFIX

/* Objective-C Classes */
#define MSAIApplication                     RENAME(MSAIApplication)
#define MSAIBase                            RENAME(MSAIBase)
#define MSAICrashData                       RENAME(MSAICrashData)
#define MSAICrashDataBinary                 RENAME(MSAICrashDataBinary)
#define MSAICrashDataHeaders                RENAME(MSAICrashDataHeaders)
#define MSAICrashDataThread                 RENAME(MSAICrashDataThread)
#define MSAICrashDataThreadFrame            RENAME(MSAICrashDataThreadFrame)
#define MSAIData                            RENAME(MSAIData)
#define MSAIDataPoint                       RENAME(MSAIDataPoint)
#define MSAIDataPointType                   RENAME(MSAIDataPointType)
#define MSAIDependencyKind                  RENAME(MSAIDependencyKind)
#define MSAIDependencySourceType            RENAME(MSAIDependencySourceType)
#define MSAIDevice                          RENAME(MSAIDevice)
#define MSAIDomain                          RENAME(MSAIDomain)
#define MSAIEnums                           RENAME(MSAIEnums)
#define MSAIEnvelope                        RENAME(MSAIEnvelope)
#define MSAIEventData                     	RENAME(MSAIEventData)
#define MSAIExceptionData                   RENAME(MSAIExceptionData)
#define MSAIExceptionDetails                RENAME(MSAIExceptionDetails)
#define MSAIInternal                        RENAME(MSAIInternal)
#define MSAILocation                        RENAME(MSAILocation)
#define MSAIMessageData                     RENAME(MSAIMessageData)
#define MSAIMetricData                      RENAME(MSAIMetricData)
#define MSAIObject                          RENAME(MSAIObject)
#define MSAIOperation                       RENAME(MSAIOperation)

#define MSAIPageViewData                    RENAME(MSAIPageViewData)
#define MSAIPageViewPerfData                RENAME(MSAIPageViewPerfData)
#define MSAIRemoteDependencyData            RENAME(MSAIRemoteDependencyData)
#define MSAISession                         RENAME(MSAISession)
#define MSAISessionState                    RENAME(MSAISessionState)
#define MSAISessionStateData                RENAME(MSAISessionStateData)
#define MSAISeverityLevel                   RENAME(MSAISeverityLevel)
#define MSAIStackFrame                      RENAME(MSAIStackFrame)
#define MSAITelemetryData                   RENAME(MSAITelemetryData)
#define MSAIUser                            RENAME(MSAIUser)

#define MSAICrashDetails                    RENAME(MSAICrashDetails)
#define MSAICrashDetailsPrivate             RENAME(MSAICrashDetailsPrivate)
#define MSAICrashManager                    RENAME(MSAICrashManager)
#define MSAICrashManagerDelegate            RENAME(MSAICrashManagerDelegate)
#define MSAICrashManagerPrivate             RENAME(MSAICrashManagerPrivate)
#define MSAICrashCXXExceptionHandler        RENAME(MSAICrashCXXExceptionHandler)
#define MSAICrashDataProvider               RENAME(MSAICrashDataProvider)

#define MSAICategoryContainer               RENAME(MSAIExceptionData)
#define ApplicationInsightsPrivate          RENAME(ApplicationInsightsPrivate)
#define MSAIContext                         RENAME(MSAIContext)
#define MSAIContextHelper                   RENAME(MSAIContextHelper)
#define MSAIContextHelperPrivate            RENAME(MSAIContextHelperPrivate)
#define MSAIContextPrivate                  RENAME(MSAIContextPrivate)
#define MSAIGZIP                            RENAME(MSAIGZIP)
#define MSAIHelper                          RENAME(MSAIHelper)

#define MSAIKeychainUtils               		RENAME(MSAIKeychainUtils)
#define MSAINullability                     RENAME(MSAINullability)
#define MSAIOrderedDictionary            		RENAME(MSAIOrderedDictionary)
#define MSAIPageViewLogging_UIViewController  RENAME(MSAIPageViewLogging_UIViewController)
#define MSAITelemetryManager            		RENAME(MSAITelemetryManager)
#define MSAITelemetryManagerPrivate         RENAME(MSAITelemetryManagerPrivate)
#define MSAIPersistence                     RENAME(MSAIPersistence)
#define MSAIPersistencePrivate         			RENAME(MSAIPersistencePrivate)

#define MSAIChannel                         RENAME(MSAIChannel)
#define MSAIChannelPrivate                  RENAME(MSAIChannelPrivate)
#define MSAIEnvelopeManager                 RENAME(MSAIEnvelopeManager)
#define MSAIEnvelopeManagerPrivate          RENAME(MSAIEnvelopeManagerPrivate)
#define MSAITelemetryContext                RENAME(MSAITelemetryContext)
#define MSAITelemetryContextPrivate         RENAME(MSAITelemetryContextPrivate)

#define MSAIAppClient                       RENAME(MSAIAppClient)
#define MSAISender                          RENAME(MSAISender)
#define MSAISenderPrivate                   RENAME(MSAISenderPrivate)
#define MSAIReachability                    RENAME(MSAIReachability)
#define MSAIReachabilityPrivate            	RENAME(MSAIReachabilityPrivate)

#define ApplicationInsightsNamespace        RENAME(ApplicationInsightsNamespace)
#define ApplicationInsights                 RENAME(ApplicationInsights)
#define ApplicationInsightsFeatureConfig    RENAME(ApplicationInsightsFeatureConfig)
#define MSAIApplicationInsights             RENAME(MSAIApplicationInsights)
#define MSAIApplicationInsightsPrivate      RENAME(MSAIApplicationInsightsPrivate)

#endif

#ifdef MSAI_PRIVATE
/* If no prefix has been defined, we need to specify our own private prefix */
#  ifndef MSAI_SDK_PREFIX
#    define MSAI_SDK_PREFIX MSAI
#  endif
#endif

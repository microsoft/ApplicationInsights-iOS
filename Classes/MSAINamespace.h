//#define MSAI_SDK_PREFIX FIXX

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
#define MSAIApplication                           RENAME(Application)
#define MSAIBase                                  RENAME(Base)
#define MSAICrashData                             RENAME(CrashData)
#define MSAICrashDataBinary                       RENAME(CrashDataBinary)
#define MSAICrashDataHeaders                      RENAME(CrashDataHeaders)
#define MSAICrashDataThread                       RENAME(CrashDataThread)
#define MSAICrashDataThreadFrame                  RENAME(CrashDataThreadFrame)
#define MSAIData                                  RENAME(Data)
#define MSAIDataPoint                             RENAME(DataPoint)
#define MSAIDataPointType                         RENAME(DataPointType)
#define MSAIDependencyKind                        RENAME(DependencyKind)
#define MSAIDependencySourceType                  RENAME(DependencySourceType)
#define MSAIDevice                                RENAME(Device)
#define MSAIDomain                                RENAME(Domain)
#define MSAIEnums                                 RENAME(Enums)
#define MSAIEnvelope                              RENAME(Envelope)
#define MSAIEventData                     	      RENAME(EventData)
#define MSAIExceptionData                         RENAME(ExceptionData)
#define MSAIExceptionDetails                      RENAME(ExceptionDetails)
#define MSAIInternal                              RENAME(Internal)
#define MSAILocation                              RENAME(Location)
#define MSAIMessageData                           RENAME(MessageData)
#define MSAIMetricData                            RENAME(MetricData)
#define MSAIObject                                RENAME(Object)
#define MSAIOperation                             RENAME(Operation)
#define MSAIPageViewData                          RENAME(PageViewData)
#define MSAIPageViewPerfData                      RENAME(PageViewPerfData)
#define MSAIRemoteDependencyData                  RENAME(RemoteDependencyData)
#define MSAISession                               RENAME(Session)
#define MSAISessionState                          RENAME(SessionState)
#define MSAISessionStateData                      RENAME(SessionStateData)
#define MSAISeverityLevel                         RENAME(SeverityLevel)
#define MSAIStackFrame                            RENAME(StackFrame)
#define MSAITelemetryData                         RENAME(TelemetryData)
#define MSAIUser                                  RENAME(User)
#define MSAICrashDetails                          RENAME(CrashDetails)
#define MSAICrashDetailsPrivate                   RENAME(CrashDetailsPrivate)
#define MSAICrashManager                          RENAME(CrashManager)
#define MSAICrashManagerDelegate                  RENAME(CrashManagerDelegate)
#define MSAICrashManagerPrivate                   RENAME(CrashManagerPrivate)
#define MSAICrashCXXExceptionHandler              RENAME(CrashCXXExceptionHandler)
#define MSAICrashDataProvider                     RENAME(CrashDataProvider)
#define MSAICategoryContainer                     RENAME(ExceptionData)
#define MSAIContext                               RENAME(Context)
#define MSAIContextHelper                         RENAME(ContextHelper)
#define MSAIContextHelperPrivate                  RENAME(ContextHelperPrivate)
#define MSAIContextPrivate                        RENAME(ContextPrivate)
#define MSAIGZIP                                  RENAME(GZIP)
#define MSAIHelper                                RENAME(Helper)
#define MSAIKeychainUtils                         RENAME(KeychainUtils)
#define MSAINullability                           RENAME(Nullability)
#define MSAIOrderedDictionary                     RENAME(OrderedDictionary)
#define MSAIPageViewLogging_UIViewController      RENAME(PageViewLogging_UIViewController)
#define MSAITelemetryManager                      RENAME(TelemetryManager)
#define MSAITelemetryManagerPrivate               RENAME(TelemetryManagerPrivate)
#define MSAIPersistence                           RENAME(Persistence)
#define MSAIPersistencePrivate                    RENAME(PersistencePrivate)
#define MSAIChannel                               RENAME(Channel)
#define MSAIChannelPrivate                        RENAME(ChannelPrivate)
#define MSAIEnvelopeManager                       RENAME(EnvelopeManager)
#define MSAIEnvelopeManagerPrivate                RENAME(EnvelopeManagerPrivate)
#define MSAITelemetryContext                      RENAME(TelemetryContext)
#define MSAITelemetryContextPrivate               RENAME(TelemetryContextPrivate)
#define MSAIAppClient                             RENAME(AppClient)
#define MSAISender                                RENAME(Sender)
#define MSAISenderPrivate                         RENAME(SenderPrivate)
#define MSAIReachability                          RENAME(Reachability)
#define MSAIReachabilityPrivate                   RENAME(ReachabilityPrivate)
#define MSAINamespace                             RENAME(Namespace)
#define ApplicationInsightsFeatureConfig          RENAME(ApplicationInsightsFeatureConfig)
#define MSAIApplicationInsights                   RENAME(ApplicationInsights)
#define MSAIApplicationInsightsPrivate            RENAME(ApplicationInsightsPrivate)

// Constants
#define kMSAIInstrumentationKey                   RENAME(InstrumentationKey)
#define kMSAITelemetrySessionId                   RENAME(TelemetrySessionId)
#define kMSAISessionAcquisitionTime               RENAME(SessionAcquisitionTime)
#define kMSAIReachabilityTypeChangedNotification  RENAME(ReachabilityTypeChangedNotification)
#define MSAIPersistenceSuccessNotification        RENAME(PersistenceSuccessNotification)
#define kMSAIReachabilityUserInfoName             RENAME(ReachabilityUserInfoName)
#define kMSAIReachabilityUserInfoType             RENAME(ReachabilityUserInfoType)
#define kMSAISessionFileName                      RENAME(SessionFileName)
#define kMSAISessionFileType                      RENAME(SessionFileType)
#define MSAISessionOperationsQueue                RENAME(SessionOperationsQueue)
#define defaultSessionExpirationTime              RENAME(DefaultSessionExpirationTime)
#define defaultMaxBatchCount                      RENAME(DefaultMaxBatchCount)
#define defaultBatchInterval                      RENAME(DefaultBatchInterval)
#define debugMaxBatchCount                        RENAME(DebugMaxBatchCount)
#define defaultFileCount                          RENAME(DefaultFileCount)
#define debugBatchInterval                        RENAME(DebugBatchInterval)
#define kMSAIApplicationDidEnterBackgroundTime    RENAME(ApplicationDidEnterBackgroundTime)
#define kMSAIApplicationWasLaunched               RENAME(ApplicationWasLaunched)
#define MSAISessionStartedNotification            RENAME(SessionStartedNotification)
#define MSAISessionEndedNotification              RENAME(SessionEndedNotification)
#define kPersistenceQueueString                   RENAME(PersistenceQueueString)
#define kHighPrioString                           RENAME(HighPrioString)
#define kRegularPrioString                        RENAME(RegularPrioString)
#define kCrashTemplateString                      RENAME(CrashTemplateString)
#define kSessionIdsString                         RENAME(SessionIdsString)
#define kFileBaseString                           RENAME(FileBaseString)
#endif

#ifdef MSAI_PRIVATE
/* If no prefix has been defined, we need to specify our own private prefix */
#  ifndef MSAI_SDK_PREFIX
#    define MSAI_SDK_PREFIX MSAI
#  endif
#endif

#if defined(__cplusplus)
#  if defined(MSAI_SDK_PREFIX)
/** @internal Define the msai namespace, automatically inserting an inline namespace containing the configured MSAI_SDK_PREFIX, if any. */
#    define PLCR_CPP_BEGIN_NS namespace msai { inline namespace MSAI_SDK_PREFIX {

/** @internal Close the definition of the `msai` namespace (and the MSAI_SDK_PREFIX inline namespace, if any). */
#    define PLCR_CPP_END_NS }}
#  else
#   define PLCR_CPP_BEGIN_NS namespace msai {
#   define PLCR_CPP_END_NS }
#  endif
#
#endif

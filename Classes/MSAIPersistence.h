#import <Foundation/Foundation.h>

/**
* A simple class that handles serialisation and deserialisation of bundles of data.
*/

@interface MSAIPersistence : NSObject

/**
* Notification that will be send on the main thread to notifiy observers of a successfully saved bundle.
* This is typically used to trigger sending to the server.
*/
FOUNDATION_EXPORT NSString *const kMSAIPersistenceSuccessNotification;


/**
* The MSAIPersistenceType determines the way how a bundle is saved.
* Bundles of type MSAIPersistenceTypeHighPriority will be loaded before all bundles if type MSAIPersistenceTypeRegular.
*/

typedef NS_ENUM(NSInteger, MSAIPersistenceType) {
  MSAIPersistenceTypeHighPriority = 0,
  MSAIPersistenceTypeRegular = 1,
  MSAIPersistenceTypeFakeCrash = 2
};

///-----------------------------------------------------------------------------
/// @name Save bundle of data
///-----------------------------------------------------------------------------

/**
* Saves the bundle and sends out a kMSAIPersistenceSuccessNotification in case of success
* for all types except MSAIPersistenceTypeFakeCrash
* @param bundle a bundle of tracked events (telemetry, crashes, ...) that will be serialized and saved.
* @param type The type of the bundle we want to save.
* @param completionBlock An optional block that will be executed after we have tried to save the bundle.
*
* @warning: The data within the array needs to implement NSCoding.
*/
+ (void)persistBundle:(NSArray *)bundle ofType:(MSAIPersistenceType)type withCompletionBlock:(void (^)(BOOL success))completionBlock;


/**
*  Convenience method for saving a bundle of data back to disk after an error (typically when sending a bundle to
*  the server fails).
*  This method will determine the priority of the bundle depending on it's content using reflection on the data within
*  the bundle. It uses the same logic as `persistBundle:ofType:withCompletionBlock:´ internally.
*  This method doesn't trigger kMSAIPersistenceSuccessNotification to avoid an endless cycle of saving & sending
*  Bundles that are persisted with this method will be sent to the server during the next attempt to send events.
*
*  @param bundle a bundle of tracked events (telemetry, crashes, ...) that will be serialized and saved.
*
*  @warning: The data within the array needs to implement NSCoding. (which is typically the case)
*/
+ (void)persistAfterErrorWithBundle:(NSArray *)bundle;

///-----------------------------------------------------------------------------
/// @name Get a bundle of saved data
///-----------------------------------------------------------------------------

/**
* Get a bundle of previously saved data from disk and deletes it using dispatch_sync.
*
* @warning Make sure nextBundle is not called from the main thread.
*
* It will return bundles of MSAIPersistenceType first.
* Between bundles of the same MSAIPersistenceType, the order is arbitrary.
* Returns 'nil' if no bundle is available
*
* @return a bundle of AppInsightsData that's ready to be sent to the server
*/

+ (NSArray *)nextBundle;

///-----------------------------------------------------------------------------
/// @name Handling of a "fake" CrashReport
///-----------------------------------------------------------------------------

/**
* Persist a "fake" crash report.
*
* @param bundle The bundle of application insights data
*/
+ (void)persistFakeReportBundle:(NSArray *)bundle;

/**
* Get the first of all saved fake crash reports (an arbitrary one in case we have several fake reports)
*
* @return a fake crash report, wrapped as a bundle
*/
+ (NSArray *)fakeReportBundle;


@end

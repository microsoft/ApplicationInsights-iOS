#import <Foundation/Foundation.h>

/**
* A simple class that handles serialisation and deserialisation of bundles of data.
*/

@interface MSAIPersistence : NSObject

FOUNDATION_EXPORT NSString *const kMSAIPersistenceSuccessNotification;


/**
* Priority for a bundle
*/

typedef NS_ENUM(NSInteger, MSAIPersistencePriority) {
  MSAIPersistencePriorityHigh = 0,
  MSAIPersistencePriorityRegular = 1,
  MSAIPersistencePriorityFakeCrash = 2
};

///-----------------------------------------------------------------------------
/// @name Save bundle of data
///-----------------------------------------------------------------------------

/**
* Saves the bundle and sends out a kMSAIPersistenceSuccessNotification in case of success
* @param bundle a bundle of tracked events (telemetry, crashes, ...) that will be serialized and saved.
* @param priority The priority of the bundle we want to save.
* @param completionBlock A block that will be executed after we have tried to save the bundle.
* @warning: The data within the array needs to implement NSCoding.
*/
+ (void)persistBundle:(NSArray *)bundle withPriority:(MSAIPersistencePriority)priority withCompletionBlock: (void (^)(BOOL success)) completionBlock;


/**
* Saves the bundle and sends out a kMSAIPersistenceSuccessNotification in case of success
* @param bundle a bundle of tracked events (telemetry, crashes, ...) that will be serialized and saved.
* @param priority The priority of the bundle we want to save.
* @warning: The data within the array needs to implement NSCoding.
*/
+ (void)persistBundle:(NSArray *)bundle withPriority:(MSAIPersistencePriority)priority;


///-----------------------------------------------------------------------------
/// @name Get a bundle of saved data
///-----------------------------------------------------------------------------

/**
* Get a bundle of previously saved data from disk and deletes it. It will return bundles with high priority before
* bundles with regular priority. Within the order of bundles within the priority is arbitrary.
* Returns 'nil' if no bundle is available
* @return a bundle of AppInsightsData that's ready to be sent to the server
*/

+ (NSArray *)nextBundle;

///-----------------------------------------------------------------------------
/// @name Handling of FakeReport
///-----------------------------------------------------------------------------

/**
* Persist a "fake" crash report.
* @param bundle The bundle of application insights data
*/
+ (void)persistFakeReportBundle:(NSArray *)bundle;

/**
* Get the first of all saved fake crash reports (an arbitrary one in case we have several fake reports)
* @return a fake crash report, wrapped as a bundle
*/
+ (NSArray *)fakeReportBundle;


@end

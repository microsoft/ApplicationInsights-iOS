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
/// @name Create an instance
///-----------------------------------------------------------------------------

/**
 *  Returns a shared MSAIPersistence object.
 *
 *  @return A singleton MSAIPersistence instance ready use
 */
+ (instancetype)sharedInstance;
  
///-----------------------------------------------------------------------------
/// @name Save/delete bundle of data
///-----------------------------------------------------------------------------

/**
 *  A queue which makes file system operations thread safe.
 */
@property (nonatomic, strong)dispatch_queue_t persistenceQueue;

/**
 *  Determines how many files (regular prio) can be on disk at a time.
 */
@property NSUInteger maxFileCount;

/**
 *  An array with all file paths, that have been requested by the sender. If the 
 *  triggers a delete, the appropriate path should also be removed here. We keep to
 *  track of requested bundles to make sure, that bundles get sent twice at the same 
 *  time by differend http operations.
 */
@property (nonatomic, strong) NSMutableArray *requestedBundlePaths;

/**
* Saves the bundle and sends out a kMSAIPersistenceSuccessNotification in case of success
* for all types except MSAIPersistenceTypeFakeCrash
* @param bundle a bundle of tracked events (telemetry, crashes, ...) that will be serialized and saved.
* @param type The type of the bundle we want to save.
* @param completionBlock An optional block that will be executed after we have tried to save the bundle.
*
* @warning: The data within the array needs to implement NSCoding.
*/
- (void)persistBundle:(NSArray *)bundle ofType:(MSAIPersistenceType)type withCompletionBlock:(void (^)(BOOL success))completionBlock;

/**
 *  Deletes the file for the given path.
 *
 *  @param path the path of the file, which should be deleted
 */
- (void)deleteBundleAtPath:(NSString *)path ;

/**
 *  Determines whether the persistence layer is able to write more files to disk.
 *
 *  @return YES if the maxFileCount has not been reached, yet (otherwise NO).
 */
- (BOOL)isFreeSpaceAvailable;

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

/**
 *  Returns the path for the next item to send. The requested path is reserved as long
 *  as leaveUpRequestedPath: gets called.
 *
 *  @see leleaveUpRequestedPath:
 *
 *  @return the path of the item, which should be sent next
 */
- (NSString *)requestNextPath;

/**
 *  Release a requested path. This method should be called after sending a file failed.
 *
 *  @param path the path that should be available for sending again.
 */
- (void)giveBackRequestedPath:(NSString *) path;

/**
 *  Return the bundle for a given path.
 *
 *  @param path the path of the bundle.
 *
 *  @return an array with all envelope objects.
 */
- (NSArray *)bundleAtPath:(NSString *)path;

///-----------------------------------------------------------------------------
/// @name Handling of a "fake" CrashReport
///-----------------------------------------------------------------------------

/**
* Persist a "fake" crash report.
*
* @param bundle The bundle of application insights data
*/
- (void)persistFakeReportBundle:(NSArray *)bundle;

/**
* Get the first of all saved fake crash reports (an arbitrary one in case we have several fake reports)
*
* @return a fake crash report, wrapped as a bundle
*/
- (NSArray *)fakeReportBundle;

@end

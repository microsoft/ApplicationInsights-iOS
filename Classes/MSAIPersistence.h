#import <Foundation/Foundation.h>
#import "MSAINullability.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The MSAIPersistenceType determines the way how a bundle is saved.
 * Bundles of type MSAIPersistenceTypeHighPriority will be loaded before all bundles if type MSAIPersistenceTypeRegular.
 */
typedef NS_ENUM(NSInteger, MSAIPersistenceType) {
  MSAIPersistenceTypeHighPriority = 0,
  MSAIPersistenceTypeRegular = 1,
};

/**
* A simple class that handles serialisation and deserialisation of bundles of data.
*/
@interface MSAIPersistence : NSObject

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
/// @name Getting a path
///-----------------------------------------------------------------------------

/**
 * Creates the path for a file depending on the MSAIPersistenceType.
 * The filename includes the timestamp.
 * For each MSAIPersistenceType, we create a folder within the app's Application Support directory directory
 *
 * @param type The MSAIPersistenceType for which a matching file URL will be returned.
*/
- (NSString *)newFileURLForPersitenceType:(MSAIPersistenceType)type;

@end
NS_ASSUME_NONNULL_END

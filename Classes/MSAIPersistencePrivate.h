#import "MSAIPersistence.h"

MSAI_ASSUME_NONNULL_BEGIN
@interface MSAIPersistence ()

/**
 * Creates the path for a file depending on the MSAIPersistenceType.
 * The filename includes the timestamp.
 * For each MSAIPersistenceType, we create a folder within the app's Application Support directory directory
 */
- (NSString *)newFileURLForPersitenceType:(MSAIPersistenceType)type;

@end
MSAI_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>

@interface MSAISessionHelper()

/**
 *  The path of the property list;
 */
@property (nonatomic, strong) NSString *filePath;

/**
 *  A NSFileManager instance, which is used to load and save property list.
 */
@property (nonatomic, strong) NSFileManager *fileManager;

/**
 *  A serial queue which makes makes insert/remove operations thread safe.
 */
@property (nonatomic, strong) dispatch_queue_t operationsQueue;

/**
 *  A Dictionary which holds content of property list in memory.
 */
@property (nonatomic, strong) NSMutableDictionary *sessionEntries;

/**
 *  An Array with sorting rules which are used to sort the content of the property list.
 */
@property (nonatomic, strong) NSArray *sortDescriptors;

/**
 *  Returns the shared instance.
 *
 *  @return the shared instance
 */
+ (id)sharedInstance;

- (void)saveFile;

- (void)loadFile;

@end

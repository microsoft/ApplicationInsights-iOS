//
// Created by Benjamin Reimold on 05.02.15.
//

#import <Foundation/Foundation.h>

/**
* A simple class that handles serialisation and deserialisation of bundles of data.
*/

@interface MSAIPersistence : NSObject



///-----------------------------------------------------------------------------
/// @name Save bundle of data
///-----------------------------------------------------------------------------

/**
*
* @param bundle a bundle of tracked events (telemetry, crashes, ...) that will be serialized and saved.
*
* @warning: The data within the array needs to implement NSCoding.
*/
+ (void)persistBundle:(NSArray *)bundle withHighPriority:(BOOL)highPriority;


///-----------------------------------------------------------------------------
/// @name Get a bundle of saved data
///-----------------------------------------------------------------------------


/**
* @return an bundle of previously saved data from disk and deletes it. It will return bundles with high priority before
* bundles with regular priority. Within the order of bundles within the priority is arbitrary.
* Returns 'nil' if no bundle is available*
*/

+ (NSArray *)nextBundle;

@end

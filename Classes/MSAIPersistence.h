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
* Prepares manager for sending out data.
*
* @param bundle a bundle of tracked events (telemetry, crashes, ...) that will be serialized and saved.
*
* @warning: The data within the array needs to implement NSCoding.
*/
+ (void)persistBundle:(NSArray *)bundle;


///-----------------------------------------------------------------------------
/// @name Get a bundle of saved data
///-----------------------------------------------------------------------------


/**
* @return an arbitrary bundle of previously saved data from disk and deletes it.
* Returns 'nil' if no bundle is available*
*/

+ (NSArray *)nextBundle;

@end

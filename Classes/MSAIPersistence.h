//
// Created by Benjamin Reimold on 05.02.15.
//

#import <Foundation/Foundation.h>

/**
* A simple class that handles serialisation and deserialisation of bundles of data.
*/

@interface MSAIPersistence : NSObject


typedef NS_ENUM(NSInteger, MSAIPersistencePriority) {
  MSAIPersistencePriorityHigh = 0,
  MSAIPersistencePriorityLow = 1
};

///-----------------------------------------------------------------------------
/// @name Save bundle of data
///-----------------------------------------------------------------------------

/**
*
* @param bundle a bundle of tracked events (telemetry, crashes, ...) that will be serialized and saved.
* @param priority The priority of the bundle we want to save.
* @param completionBlock A block that will be executed after we have tried to save the bundle.
* @warning: The data within the array needs to implement NSCoding.
*/
+ (void)persistBundle:(NSArray *)bundle withPriority:(MSAIPersistencePriority)priority withCompletionBlock: (void (^)(BOOL success)) completionBlock;


/**
*
*/
+ (void)persistBundle:(NSArray *)bundle withPriority:(MSAIPersistencePriority)priority;
//TODO Provide documentation

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

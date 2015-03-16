#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "AppInsights.h"
#import "MSAIEnvelope.h"
#import "MSAIPersistence.h"

typedef void (^MSAIPersistenceTestBlock)(BOOL);

@interface MSAIPersistenceTest : XCTestCase

@end

@implementation MSAIPersistenceTest {
  MSAIPersistence *_sut;
}

- (void)setUp {
  [super setUp];
  _sut = [MSAIPersistence sharedInstance];
  _sut.maxFileCount = 20;
}

- (void)tearDown{
  [super tearDown];
  [self deleteAllFiles];
}

- (void)testNoBundles {
  NSString *nextPath = [_sut requestNextPath];
  XCTAssertNil(nextPath);
}

- (void)testIfItPersistsRegular {
  MSAIOrderedDictionary *dict = [MSAIOrderedDictionary new];
  XCTAssertTrue([self createFileForDict:dict withType:MSAIPersistenceTypeRegular]);
}

- (void)testReturnsHighPrioFirst {
  // Create regular & high prio file
  NSDictionary *highPrioDict = @{@"prio":@"high"};
  NSDictionary *regularPrioDict = @{@"prio":@"regular"};
  [self createFileForDict:highPrioDict withType:MSAIPersistenceTypeHighPriority];
  [self createFileForDict:regularPrioDict withType:MSAIPersistenceTypeRegular];
  
  // First requested file should be high prio
  NSString *nextPath = [_sut requestNextPath];
  NSData *data = [_sut dataAtPath:nextPath];
  XCTAssertTrue([data isEqual:[_sut dataForBundle:@[highPrioDict] withPersistenceTye:MSAIPersistenceTypeHighPriority]]);
  
  // Once this file has been locked, we'll get the file with regular prio
  nextPath = [_sut requestNextPath];
  data = [_sut dataAtPath:nextPath];
  XCTAssertTrue([data isEqual:[_sut dataForBundle:@[regularPrioDict] withPersistenceTye:MSAIPersistenceTypeRegular]]);
}

- (void)testDeletionWorks {
  // Create file
  [self createFileForDict:@{} withType:MSAIPersistenceTypeRegular];
  NSString *nextPath = [_sut requestNextPath];
  XCTAssertNotNil([_sut dataAtPath:nextPath]);
  
  //Delete it again
  [_sut deleteFileAtPath:nextPath];
  nextPath = [_sut requestNextPath];
  XCTAssertNil(nextPath);
}

- (void)testNextPathNotEmptyWhenFilePersisted{
  NSString *nextPath = [_sut requestNextPath];
  XCTAssertNil(nextPath);
  
  [self createFileForDict:@{} withType:MSAIPersistenceTypeRegular];
  nextPath = [_sut requestNextPath];
  XCTAssertNotNil(nextPath);
}

- (void)testDataAtPathReturnsCorrectFile{
  // Save data to disk
  NSString *key = @"myKey";
  NSString *value = @"myValue";
  NSDictionary *dict = @{key:value};
  [self createFileForDict:dict withType:MSAIPersistenceTypeRegular];
  
  // Test
  NSString *nextPath = [_sut requestNextPath];
  NSData *jsonData = [_sut dataAtPath:nextPath];
  XCTAssertNotNil(jsonData);
  NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
  XCTAssertNotNil(json);
  XCTAssertTrue([json[0][key] isEqualToString:value]);
}

- (void)testIfIsFreeSpaceAvailableWorks{
  // Max 1 file at a time, we currently have 0
  _sut.maxFileCount = 1;
  [self updateFileCount];
  XCTAssertTrue([_sut isFreeSpaceAvailable]);
  
  // Save a file, so we will reach the max count
  [self createFileForDict:@{} withType:MSAIPersistenceTypeRegular];
  [self updateFileCount];
  XCTAssertFalse([_sut isFreeSpaceAvailable]);
}

- (void)testRequestedPathIsBlocked{
  // Create file, make sure it has not been requested yet
  [self createFileForDict:@{} withType:MSAIPersistenceTypeHighPriority];
  XCTAssertTrue(_sut.requestedBundlePaths.count == 0);
  
  // Path is added to list after path was requested
  NSString *path = [_sut requestNextPath];
  XCTAssertTrue(_sut.requestedBundlePaths.count == 1);
  XCTAssertEqual(_sut.requestedBundlePaths[0], path);
}

- (void)testRequestedPathIsReleasedWhenOnGiveBack{
  [self createFileForDict:@{} withType:MSAIPersistenceTypeRegular];
  
  // Request path for sending
  NSString *path = [_sut requestNextPath];
  XCTAssertLessThanOrEqual(_sut.requestedBundlePaths.count, 1);
  
  // Release path again (e.g. no connection)
  [_sut giveBackRequestedPath:path];
  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                           beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  XCTAssertTrue(_sut.requestedBundlePaths.count == 0);
}

- (void)testRequestedPathIsReleasedOnDeletion {
  [self createFileForDict:@{} withType:MSAIPersistenceTypeRegular];
  
  // Request path for sending
  NSString *path = [_sut requestNextPath];
  XCTAssertTrue(_sut.requestedBundlePaths.count == 1);
  
  // Release path again (e.g. successfully sent)
  [_sut deleteFileAtPath:path];
  XCTAssertTrue(_sut.requestedBundlePaths.count == 0);
}

- (void)testFolderPathForPersistenceTypePerformance {
  [self measureBlock:^{
    for (int i = 0; i < 1000; ++i) {
      [_sut folderPathForPersistenceType:MSAIPersistenceTypeHighPriority];
    }
    for (int i = 0; i < 1000; ++i) {
      [_sut folderPathForPersistenceType:MSAIPersistenceTypeRegular];
    }
    for (int i = 0; i < 1000; ++i) {
      [_sut folderPathForPersistenceType:MSAIPersistenceTypeCrashTemplate];
    }
  }];
}

- (void)testOverwriteCrashTemplateWorks {
  
  // Create first crash template
  [self createFileForDict:@{} withType:MSAIPersistenceTypeCrashTemplate];
  XCTAssertEqual([self fileCountForType:MSAIPersistenceTypeCrashTemplate], 1);
  
  // Create a new crash template, which should overwrite the first one
  [self createFileForDict:@{} withType:MSAIPersistenceTypeCrashTemplate];
  XCTAssertEqual([self fileCountForType:MSAIPersistenceTypeCrashTemplate], 1);
}

#pragma mark - Helper

-(BOOL)createFileForDict:(NSDictionary *)dict withType:(MSAIPersistenceType)type{
  
  __block BOOL success = NO;
  XCTestExpectation *documentOpenExpectation = [self expectationWithDescription:@"File saved to disk"];
  [_sut persistBundle:@[dict] ofType:type enableNotifications:NO withCompletionBlock:^(BOOL success) {
    [documentOpenExpectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    success = YES;
  }];
  return success;
}

-(void)deleteAllFiles{
  [_sut.requestedBundlePaths removeAllObjects];
  //Delete all bundles to make sure we have a clean dir next time
  NSString *nextPath = [_sut requestNextPath];
  
  while (nextPath) {
    [_sut deleteFileAtPath:nextPath];
    nextPath = [_sut requestNextPath];
  }
}

-(void)updateFileCount{
  // Due to permormance reasons the file count only gets updated when a file is requested
  [_sut requestNextPath];
}

- (NSUInteger)fileCountForType:(MSAIPersistenceType)type{
  NSString *directoryPath = [_sut folderPathForPersistenceType:type];
  NSError *error;
  NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:directoryPath]
                                                     includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                        options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                          error:&error];

  return fileNames.count;
}

@end

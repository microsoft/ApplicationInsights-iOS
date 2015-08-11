#import <XCTest/XCTest.h>
#import "MSAICrashDataProviderPrivate.h"
#import "MSAIStackFrame.h"
#import "ApplicationInsightsFeatureConfig.h"

@interface MSAICrashDataProviderTests : XCTestCase

@end

@implementation MSAICrashDataProviderTests

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void) testParseSingleManagedStackframeFromStringWorks {
  // Setup
  NSString *testString1 = @"  at My.Method/Name (My.Parameter Type) in My/Filename:123 ";
  // Test
  MSAIStackFrame *frame1 = [MSAICrashDataProvider stackframeForStackLine:testString1];
  // Verify
  XCTAssertEqualObjects(@"My.Method/Name (My.Parameter Type)", frame1.method);
  XCTAssertEqualObjects(@"My/Filename", frame1.fileName);
  XCTAssertEqual(123, [frame1.line intValue]);
  
  // Setup
  NSString *testString2 = @"at  My.Method/Name(My.ParameterType) in My/Filename:noNumber ";
  // Test
  MSAIStackFrame *frame2 = [MSAICrashDataProvider stackframeForStackLine:testString2];
  // Verify
  
  XCTAssertEqualObjects(@"My.Method/Name(My.ParameterType)", frame2.method);
  XCTAssertNil(frame2.fileName);
  XCTAssertNil(frame2.line);
  
  // Setup
  NSString *testString3 = @"at SampleApp.Application.Main (System.String[] args) [0x00000] in <filename unknown>:0 ";
  // Test
  MSAIStackFrame *frame3 = [MSAICrashDataProvider stackframeForStackLine:testString3];
  // Verify
  XCTAssertEqualObjects(@"SampleApp.Application.Main (System.String[] args)", frame3.method);
  XCTAssertEqualObjects(@"<filename unknown>", frame3.fileName);
  XCTAssertNil(frame3.line);
  
  NSString *testString4 = @"  at (wrapper managed-to-native) UIKit.UIApplication:UIApplicationMain (int,string[],intptr,intptr) ";
  // Test
  MSAIStackFrame *frame4 = [MSAICrashDataProvider stackframeForStackLine:testString4];
  // Verify
  XCTAssertEqualObjects(@"(wrapper managed-to-native) UIKit.UIApplication:UIApplicationMain (int,string[],intptr,intptr)", frame4.method);
  XCTAssertNil(frame4.fileName);
  XCTAssertNil(frame4.line);
  
  NSString *testString5 = @"My.Method/Name(My.ParameterType) in My/Filename:123    ";
  // Test
  MSAIStackFrame *frame5 = [MSAICrashDataProvider stackframeForStackLine:testString5];
  // Verify
  XCTAssertNil(frame5);
}
- (void)testiOSImages {
  NSString *processPath = nil;
  NSString *appBundlePath = nil;
  
  appBundlePath = @"/private/var/mobile/Containers/Bundle/Application/9107B4E2-CD8C-486E-A3B2-82A5B818F2A0/MyApp.app";
  
  // Test with iOS App
  processPath = [appBundlePath stringByAppendingString:@"/MyApp"];
  [self testiOSNonAppSpecificImagesForProcessPath:processPath];
  [self testAppBinaryWithImagePath:processPath processPath:processPath];
  [self testiOSAppFrameworkAtProcessPath:processPath appBundlePath:appBundlePath];
  
  // Test with iOS App Extension
  processPath = [appBundlePath stringByAppendingString:@"/Plugins/MyAppExtension.appex/MyAppExtension"];
  [self testiOSNonAppSpecificImagesForProcessPath:processPath];
  [self testAppBinaryWithImagePath:processPath processPath:processPath];
  [self testiOSAppFrameworkAtProcessPath:processPath appBundlePath:appBundlePath];
}

#pragma mark - Test Helper

- (void)testAppBinaryWithImagePath:(NSString *)imagePath processPath:(NSString *)processPath {
  MSAIBinaryImageType imageType = [MSAICrashDataProvider imageTypeForImagePath:imagePath
                                                                            processPath:processPath];
  XCTAssert((imageType == MSAIBinaryImageTypeAppBinary), @"Test app %@ with process %@", imagePath, processPath);
}

#pragma mark - iOS Test Helper

- (void)testiOSAppFrameworkAtProcessPath:(NSString *)processPath appBundlePath:(NSString *)appBundlePath {
  NSString *frameworkPath = [appBundlePath stringByAppendingString:@"/Frameworks/MyFrameworkLib.framework/MyFrameworkLib"];
  MSAIBinaryImageType imageType = [MSAICrashDataProvider imageTypeForImagePath:frameworkPath
                                                                            processPath:processPath];
  XCTAssert((imageType == MSAIBinaryImageTypeAppFramework), @"Test framework %@ with process %@", frameworkPath, processPath);
  
  frameworkPath = [appBundlePath stringByAppendingString:@"/Frameworks/libSwiftMyLib.framework/libSwiftMyLib"];
  imageType = [MSAICrashDataProvider imageTypeForImagePath:frameworkPath
                                                         processPath:processPath];
  XCTAssert((imageType == MSAIBinaryImageTypeAppFramework), @"Test framework %@ with process %@", frameworkPath, processPath);
  
  NSMutableArray *swiftFrameworkPaths = [NSMutableArray new];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Frameworks/libswiftCore.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Frameworks/libswiftDarwin.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Frameworks/libswiftDispatch.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Frameworks/libswiftFoundation.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Frameworks/libswiftObjectiveC.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Frameworks/libswiftSecurity.dylib"]];
  [swiftFrameworkPaths addObject:[appBundlePath stringByAppendingString:@"/Frameworks/libswiftCoreGraphics.dylib"]];
  
  for (NSString *imagePath in swiftFrameworkPaths) {
    MSAIBinaryImageType imageType = [MSAICrashDataProvider imageTypeForImagePath:imagePath
                                                                              processPath:processPath];
    XCTAssert((imageType == MSAIBinaryImageTypeOther), @"Test swift image %@ with process %@", imagePath, processPath);
  }
}

- (void)testiOSNonAppSpecificImagesForProcessPath:(NSString *)processPath {
  // system test paths
  NSMutableArray *nonAppSpecificImagePaths = [NSMutableArray new];
  
  // iOS frameworks
  [nonAppSpecificImagePaths addObject:@"/System/Library/AccessibilityBundles/AccessibilitySettingsLoader.bundle/AccessibilitySettingsLoader"];
  [nonAppSpecificImagePaths addObject:@"/System/Library/Frameworks/AVFoundation.framework/AVFoundation"];
  [nonAppSpecificImagePaths addObject:@"/System/Library/Frameworks/AVFoundation.framework/libAVFAudio.dylib"];
  [nonAppSpecificImagePaths addObject:@"/System/Library/PrivateFrameworks/AOSNotification.framework/AOSNotification"];
  [nonAppSpecificImagePaths addObject:@"/System/Library/PrivateFrameworks/Accessibility.framework/Frameworks/AccessibilityUI.framework/AccessibilityUI"];
  [nonAppSpecificImagePaths addObject:@"/System/Library/PrivateFrameworks/Accessibility.framework/Frameworks/AccessibilityUIUtilities.framework/AccessibilityUIUtilities"];
  [nonAppSpecificImagePaths addObject:@"/usr/lib/libAXSafeCategoryBundle.dylib"];
  [nonAppSpecificImagePaths addObject:@"/usr/lib/libAXSpeechManager.dylib"];
  [nonAppSpecificImagePaths addObject:@"/usr/lib/libAccessibility.dylib"];
  [nonAppSpecificImagePaths addObject:@"/usr/lib/system/libcache.dylib"];
  [nonAppSpecificImagePaths addObject:@"/usr/lib/system/libcommonCrypto.dylib"];
  [nonAppSpecificImagePaths addObject:@"/usr/lib/system/libcompiler_rt.dylib"];
  
  // iOS Jailbreak libraries
  [nonAppSpecificImagePaths addObject:@"/Library/MobileSubstrate/MobileSubstrate.dylib"];
  [nonAppSpecificImagePaths addObject:@"/Library/MobileSubstrate/DynamicLibraries/WeeLoader.dylib"];
  [nonAppSpecificImagePaths addObject:@"/Library/Frameworks/CydiaSubstrate.framework/Libraries/SubstrateLoader.dylib"];
  [nonAppSpecificImagePaths addObject:@"/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate"];
  [nonAppSpecificImagePaths addObject:@"/Library/MobileSubstrate/DynamicLibraries/WinterBoard.dylib"];
  
  for (NSString *imagePath in nonAppSpecificImagePaths) {
    MSAIBinaryImageType imageType = [MSAICrashDataProvider imageTypeForImagePath:imagePath
                                                                              processPath:processPath];
    XCTAssert((imageType == MSAIBinaryImageTypeOther), @"Test other image %@ with process %@", imagePath, processPath);
  }
}

@end

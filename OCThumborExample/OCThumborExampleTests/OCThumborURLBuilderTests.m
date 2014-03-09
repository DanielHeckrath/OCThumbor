//
//  OCThumborURLBuilderTests.m
//  OCThumborExample
//
//  Created by Daniel Heckrath on 09.03.14.
//  Copyright (c) 2014 Codeserv. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCThumbor/OCThumbor.h>

@interface OCThumborURLBuilderTests : XCTestCase

@end

@implementation OCThumborURLBuilderTests {
    OCThumbor *_safe;
    OCThumbor *_unsafe;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
    _unsafe = [OCThumbor createWithHost:@"/"];
    _safe = [OCThumbor createWithHost:@"/" key:@"test"];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testNoConfig {
    NSString *actual = [[_unsafe buildImage:@"http://a.com/b.png"] toUrl];
    NSString *expected = @"/unsafe/http://a.com/b.png";
    XCTAssertTrue([actual isEqualToString:expected], @"Actual URL(%@) is different to expected URL(%@)", actual, expected);
}

- (void)testComplexUnsafeBuild {
    NSString *expected = @"/unsafe/10x10:90x90/40x40/filters:watermark(/unsafe/20x20/b.com/c.jpg,10,10,0):round_corner(5,255,255,255)/a.com/b.png";
    
    OCThumborURLBuilder *builder = [_unsafe buildImage:@"a.com/b.png"];
    [builder cropTop:10 left:10 right:90 bottom:90];
    [builder resizeWidth:40 height:40];
    [builder filter:
     th_watermarkBXY([[_unsafe buildImage:@"b.com/c.jpg"] resizeWidth:20 height:20], 10, 10),
     th_roundCorner(5),
     nil];
    
    NSString *actual = [builder toUrl];
    
    XCTAssertTrue([actual isEqualToString:expected], @"Actual URL(%@) is different to expected URL(%@)", actual, expected);
}

- (void)testComplexSafeBuild {
    NSString *expected = @"/X_5ze5WdyTObULp4Toj6mHX-R1U=/10x10:90x90/40x40/filters:watermark(/unsafe/20x20/b.com/c.jpg,10,10,0):round_corner(5,255,255,255)/a.com/b.png";
    
    OCThumborURLBuilder *builder = [_safe buildImage:@"a.com/b.png"];
    [builder cropTop:10 left:10 right:90 bottom:90];
    [builder resizeWidth:40 height:40];
    [builder filter:
     th_watermarkBXY([[_unsafe buildImage:@"b.com/c.jpg"] resizeWidth:20 height:20], 10, 10),
     th_roundCorner(5),
     nil];
    
    NSString *actual = [builder toUrl];
    
    XCTAssertTrue([actual isEqualToString:expected], @"Actual URL(%@) is different to expected URL(%@)", actual, expected);
}

- (void)testComplexLegacySafeBuild {
    NSString *expected = @"/xrUrWUD_ZhogPh-rvPF5VhgWENCgh-mzknoAEZ7dcX_xa7sjqP1ff9hQQq_ORAKmuCr5pyyU3srXG7BUdWUzBqp3AIucz8KiGsmHw1eFe4SBWhp1wSQNG49jSbbuHaFF_4jy5oV4Nh821F4yqNZfe6CIvjbrr1Vw2aMPL4bE7VCHBYE9ukKjVjLRiW3nLfih/a.com/b.png";
    
    OCThumborURLBuilder *builder = [_safe buildImage:@"a.com/b.png"];
    [builder cropTop:10 left:10 right:90 bottom:90];
    [builder resizeWidth:40 height:40];
    [builder filter:
     th_watermarkBXY([[_unsafe buildImage:@"b.com/c.jpg"] resizeWidth:20 height:20], 10, 10),
     th_roundCorner(5),
     nil];
    [builder legacy];
    
    NSString *actual = [builder toUrl];
    
    XCTAssertTrue([actual isEqualToString:expected], @"Actual URL(%@) is different to expected URL(%@)", actual, expected);
}

- (void)testKeyChangesToUrlToSafeBuild {
    OCThumborURLBuilder *url1 = [_unsafe buildImage:@"a.com/b.png"];
    XCTAssertNil(url1.key);
    XCTAssertTrue([[url1 toUrl] hasPrefix:@"/unsafe/"]);
    OCThumborURLBuilder *url2 = [_safe buildImage:@"a.com/b.png"];
    XCTAssertNotNil(url2.key);
    XCTAssertFalse([[url2 toUrl] hasPrefix:@"/unsafe/"]);
}

- (void)testBuildMeta {
    XCTAssertTrue([[[_unsafe buildImage:@"a.com/b.png"] toMeta] hasPrefix:@"/meta/"]);
}

- (void)testSafeUrlCanStillBuildUnsafe {
    NSString *expected = @"/unsafe/a.com/b.png";
    NSString *actual = [[_safe buildImage:@"a.com/b.png"] toUrlUnsafe];
    XCTAssertTrue([actual isEqualToString:expected], @"Actual URL(%@) is different to expected URL(%@)", actual, expected);
}

- (void)testSafeMetaUrlCanStillBuildUnsafe {
    NSString *expected = @"/meta/a.com/b.png";
    NSString *actual = [[_safe buildImage:@"a.com/b.png"] toMetaUnsafe];
    XCTAssertTrue([actual isEqualToString:expected], @"Actual URL(%@) is different to expected URL(%@)", actual, expected);
}

- (void)testResize {
    OCThumborURLBuilder *url = [_unsafe buildImage:@"a.com/b.png"];
    XCTAssertFalse(url.hasResize);
    
    [url resizeWidth:10 height:5];
    XCTAssertTrue(url.hasResize);
    XCTAssertEqual(url.resizeWidth, 10);
    XCTAssertEqual(url.resizeHeight, 5);
    XCTAssertTrue([[url toUrl] isEqualToString:@"/unsafe/10x5/a.com/b.png"]);
    
    url = [_unsafe buildImage:@"b.com/c.png"];
    XCTAssertFalse(url.hasResize);
    
    [url resizeWidth:THUMBOR_ORIGINAL_SIZE height:THUMBOR_ORIGINAL_SIZE];
    XCTAssertTrue(url.hasResize);
    XCTAssertEqual(url.resizeWidth, INT_MIN);
    XCTAssertEqual(url.resizeHeight, INT_MIN);
    XCTAssertTrue([[url toUrl] isEqualToString:@"/unsafe/origxorig/b.com/c.png"]);
}

- (void)testResizeAndFitIn {
    OCThumborURLBuilder *url = [_unsafe buildImage:@"a.com/b.png"];
    [url resizeWidth:10 height:5];
    XCTAssertFalse(url.hasFitIn);
    [url fitIn];
    XCTAssertTrue(url.hasFitIn);
    XCTAssertTrue([[url toUrl] isEqualToString:@"/unsafe/fit-in/10x5/a.com/b.png"]);
}

- (void)testResizeAndFlip {
    OCThumborURLBuilder *image1 = [[[_unsafe buildImage:@"a.com/b.png"] resizeWidth:10 height:5] flipHorizontally];
    XCTAssertTrue(image1.hasFlipHorizontally);
    XCTAssertTrue([[image1 toUrl] isEqualToString:@"/unsafe/-10x5/a.com/b.png"]);
    
    
    OCThumborURLBuilder *image2 = [[[_unsafe buildImage:@"a.com/b.png"] resizeWidth:10 height:5] flipVertically];
    XCTAssertTrue(image2.hasFlipVertically);
    XCTAssertTrue([[image2 toUrl] isEqualToString:@"/unsafe/10x-5/a.com/b.png"]);
    
    
    OCThumborURLBuilder *image3 = [[[[_unsafe buildImage:@"a.com/b.png"] resizeWidth:10 height:5] flipHorizontally] flipVertically];
    XCTAssertTrue(image3.hasFlipHorizontally);
    XCTAssertTrue(image3.hasFlipVertically);
    XCTAssertTrue([[image3 toUrl] isEqualToString:@"/unsafe/-10x-5/a.com/b.png"]);
}

- (void)testCrop {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"a.com/b.png"];
    XCTAssertFalse(image.hasCrop);
    [image cropTop:1 left:2 right:3 bottom:4];
    XCTAssertTrue(image.hasCrop);
    XCTAssertEqual(image.cropTop, 1);
    XCTAssertEqual(image.cropLeft, 2);
    XCTAssertEqual(image.cropBottom, 3);
    XCTAssertEqual(image.cropRight, 4);
    XCTAssertTrue([[image toUrl] isEqualToString:@"/unsafe/2x1:4x3/a.com/b.png"]);
}

- (void)testCropAndSmart {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    [image cropTop:1 left:2 right:3 bottom:4];
    XCTAssertFalse(image.isSmart);
    [image smart];
    XCTAssertTrue(image.isSmart);
    XCTAssertTrue([[image toUrl] isEqualToString:@"/unsafe/2x1:4x3/smart/http://a.com/b.png"]);
}

- (void)testCannotFlipHorizontalWithoutResize {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.hasResize);
    XCTAssertFalse(image.hasFlipHorizontally);
    
    @try {
        [image flipHorizontally];
    } @catch (NSException *expected) {
    }
    
    XCTAssertFalse(image.hasFlipHorizontally);
}

- (void)testCannotFlipVerticalWithoutResize {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.hasResize);
    XCTAssertFalse(image.hasFlipVertically);
    
    @try {
        [image flipVertically];
    } @catch (NSException *expected) {
    }
    
    XCTAssertFalse(image.hasFlipVertically);
}

- (void)testCannotFitInWithoutCrop {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.hasCrop);
    XCTAssertFalse(image.hasFitIn);
    
    @try {
        [image fitIn];
    } @catch (NSException *expected) {
    }
    
    XCTAssertFalse(image.hasFitIn);
}

- (void)testCannotSmartWithoutCrop {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.hasCrop);
    XCTAssertFalse(image.isSmart);
    
    XCTAssertThrows([image smart]);
    
    XCTAssertFalse(image.isSmart);
}

- (void)testDoubleAlignmentMethodSetsBoth {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    [image cropTop:0 left:0 right:1 bottom:1];
    XCTAssertEqual(image.cropVerticalAlign, ThumborVerticalAlignNone);
    XCTAssertEqual(image.cropHorizontalAlign, ThumborHorizontalAlignNone);
    [image alignVertically:ThumborVerticalAlignMiddle horizontally:ThumborHorizontalAlignCenter];
    XCTAssertEqual(image.cropVerticalAlign, ThumborVerticalAlignMiddle);
    XCTAssertEqual(image.cropHorizontalAlign, ThumborHorizontalAlignCenter);
}

- (void)testTrim {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.isTrim);
    [image trim:ThumborTrimPixelColorTopLeft withTolerance:100];
    XCTAssertTrue(image.isTrim);
    XCTAssertEqual(image.trimPixelColor, ThumborTrimPixelColorTopLeft);
    XCTAssertEqual(image.trimColorTolerance, 100);
    XCTAssertTrue([[image toUrl] isEqualToString:@"/unsafe/trim:top-left:100/http://a.com/b.png"]);
}

- (void)testCannotAlignWithoutCrop {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.hasCrop);
    XCTAssertEqual(image.cropHorizontalAlign, ThumborHorizontalAlignNone);
    
    XCTAssertThrows([image horizontalAlign:ThumborHorizontalAlignCenter], @"Allowed horizontal crop align without crop.");
    XCTAssertThrows([image verticalAlign:ThumborVerticalAlignMiddle], @"Allowed vertical crop align without crop.");
}

- (void)testCannotIssueBadCrop {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    
    XCTAssertThrows([image cropTop:-1 left:0 right:1 bottom:1], @"Bad top value allowed.");
    XCTAssertThrows([image cropTop:0 left:-1 right:1 bottom:1], @"Bad left value allowed.");
    XCTAssertThrows([image cropTop:0 left:0 right:-1 bottom:1], @"Bad right value allowed.");
    XCTAssertThrows([image cropTop:0 left:0 right:1 bottom:-1], @"Bad bottom value allowed.");
    XCTAssertThrows([image cropTop:1 left:1 right:0 bottom:1], @"Right value less than left value allowed.");
    XCTAssertThrows([image cropTop:1 left:0 right:1 bottom:0], @"Bottom value less than top value allowed.");
}

- (void)testCannotIssueBadResize {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    
    XCTAssertThrows([image resizeWidth:-1 height:5], @"Bad width value allowed.");
    XCTAssertThrows([image resizeWidth:10 height:-400], @"Bad height value allowed.");
    XCTAssertThrows([image resizeWidth:0 height:0], @"Zero resize value allowed.");
}

- (void)testCannotBuildSafeWithoutKey {
    XCTAssertThrows([[_unsafe buildImage:@"foo"] toUrlSafe], @"toUrlSafe succeeds without key.");
}

- (void)testFilterBrightnessInvalidValues {
    XCTAssertThrows(th_brightness(-101), @"Brightness allowed invalid value.");
    XCTAssertThrows(th_brightness(101), @"Brightness allowed invalid value.");
}

- (void)testFilterBrightnessFormat {
    XCTAssertTrue([th_brightness(30) isEqualToString:@"brightness(30)"]);
}

- (void)testFilterContrastInvalidValues {
    XCTAssertThrows(th_contrast(-101), @"Contrast allowed invalid value.");
    XCTAssertThrows(th_contrast(101), @"Contrast allowed invalid value.");
}

- (void)testFilterContrastFormat {
    XCTAssertTrue([th_contrast(30) isEqualToString:@"contrast(30)"]);
}

- (void)testFilterNoiseInvalidValues {
    XCTAssertThrows(th_noise(-1), @"Noise allowed invalid value.");
    XCTAssertThrows(th_noise(101), @"Noise allowed invalid value.");
}

- (void)testFilterNoiseFormat {
    XCTAssertTrue([th_noise(30) isEqualToString:@"noise(30)"]);
}

- (void)testFilterQualityInvalidValues {
    XCTAssertThrows(th_quality(-1), @"Quality allowed invalid value.");
    XCTAssertThrows(th_quality(101), @"Quality allowed invalid value.");
}

- (void)testFilterQualityFormat {
    XCTAssertTrue([th_quality(30) isEqualToString:@"quality(30)"]);
}

- (void)testFilterRgbInvalidValues {
    XCTAssertThrows(th_rgb(-101, 0, 0), @"RGB allowed invalid value.");
    XCTAssertThrows(th_rgb(0, -101, 0), @"RGB allowed invalid value.");
    XCTAssertThrows(th_rgb(0, 0, -101), @"RGB allowed invalid value.");
    XCTAssertThrows(th_rgb(101, 0, 0), @"RGB allowed invalid value.");
    XCTAssertThrows(th_rgb(0, 101, 0), @"RGB allowed invalid value.");
    XCTAssertThrows(th_rgb(0, 0, 101), @"RGB allowed invalid value.");
}

- (void)testFilterRgbFormat {
    XCTAssertTrue([th_rgb(-30, 40, -75) isEqualToString:@"rgb(-30,40,-75)"]);
}

- (void)testFilterRoundCornerInvalidValues {
    XCTAssertThrows(th_roundCorner(0), @"Round corner allowed invalid value.");
    XCTAssertThrows(th_roundCorner(-50), @"Round corner allowed invalid value.");
    XCTAssertThrows(th_roundCornerOC(1, -1, 0xFFFFFF), @"Round corner allowed invalid value.");
}

- (void)testFilterRoundCornerFormat {
    XCTAssertTrue([th_roundCorner(10) isEqualToString:@"round_corner(10,255,255,255)"]);
    XCTAssertTrue([th_roundCornerC(10, 0xFF1010) isEqualToString:@"round_corner(10,255,16,16)"]);
    XCTAssertTrue([th_roundCornerOC(10, 15, 0xFF1010) isEqualToString:@"round_corner(10|15,255,16,16)"]);
}

- (void)testFilterSharpenFormat {
    XCTAssertTrue([th_sharpen(3, 4, YES) isEqualToString:@"sharpen(3.0,4.0,true)"]);
    XCTAssertTrue([th_sharpen(3, 4, NO) isEqualToString:@"sharpen(3.0,4.0,false)"]);
    XCTAssertTrue([th_sharpen(3.1, 4.2, YES) isEqualToString:@"sharpen(3.1,4.2,true)"]);
    XCTAssertTrue([th_sharpen(3.1, 4.2, NO) isEqualToString:@"sharpen(3.1,4.2,false)"]);
}

- (void)testFilterFillingFormat {
    XCTAssertTrue([th_fill(0xFF2020) isEqualToString:@"fill(ff2020)"]);
    XCTAssertTrue([th_fill(0xABFF2020) isEqualToString:@"fill(ff2020)"]);
}

- (void)testFilterFrameFormat {
    XCTAssertTrue([th_frame(@"a.png") isEqualToString:@"frame(a.png)"]);
}

@end

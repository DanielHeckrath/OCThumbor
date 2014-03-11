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
    builder.cropEdgeInsets = CropEdgeInsetsMake(10, 10, 90, 90);
    builder.resizeSize = ResizeSizeMake(40, 40);
    
    OCThumborURLBuilder *watermark = [_unsafe buildImage:@"b.com/c.jpg"];
    watermark.resizeSize = ResizeSizeMake(20, 20);
    
    builder.filter = @[watermarkBXY(watermark, 10, 10), roundCorner(5)];
    
    NSString *actual = [builder toUrl];
    
    XCTAssertTrue([actual isEqualToString:expected], @"Actual URL(%@) is different to expected URL(%@)", actual, expected);
}

- (void)testComplexSafeBuild {
    NSString *expected = @"/X_5ze5WdyTObULp4Toj6mHX-R1U=/10x10:90x90/40x40/filters:watermark(/unsafe/20x20/b.com/c.jpg,10,10,0):round_corner(5,255,255,255)/a.com/b.png";
    
    OCThumborURLBuilder *builder = [_safe buildImage:@"a.com/b.png"];
    
    builder.cropEdgeInsets = CropEdgeInsetsMake(10, 10, 90, 90);
    builder.resizeSize = ResizeSizeMake(40, 40);
    
    OCThumborURLBuilder *watermark = [_unsafe buildImage:@"b.com/c.jpg"];
    watermark.resizeSize = ResizeSizeMake(20, 20);
    
    builder.filter = @[watermarkBXY(watermark, 10, 10), roundCorner(5)];
    
    NSString *actual = [builder toUrl];
    
    XCTAssertTrue([actual isEqualToString:expected], @"Actual URL(%@) is different to expected URL(%@)", actual, expected);
}

- (void)testComplexLegacySafeBuild {
    NSString *expected = @"/xrUrWUD_ZhogPh-rvPF5VhgWENCgh-mzknoAEZ7dcX_xa7sjqP1ff9hQQq_ORAKmuCr5pyyU3srXG7BUdWUzBqp3AIucz8KiGsmHw1eFe4SBWhp1wSQNG49jSbbuHaFF_4jy5oV4Nh821F4yqNZfe6CIvjbrr1Vw2aMPL4bE7VCHBYE9ukKjVjLRiW3nLfih/a.com/b.png";
    
    OCThumborURLBuilder *builder = [_safe buildImage:@"a.com/b.png"];
    builder.cropEdgeInsets = CropEdgeInsetsMake(10, 10, 90, 90);
    builder.resizeSize = ResizeSizeMake(40, 40);
    
    OCThumborURLBuilder *watermark = [_unsafe buildImage:@"b.com/c.jpg"];
    watermark.resizeSize = ResizeSizeMake(20, 20);
    
    builder.filter = @[watermarkBXY(watermark, 10, 10), roundCorner(5)];
    builder.legacy = YES;
    
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
    
    url.resizeSize = ResizeSizeMake(10, 5);
    XCTAssertTrue(url.hasResize);
    XCTAssertEqual(url.resizeSize.width, 10);
    XCTAssertEqual(url.resizeSize.height, 5);
    XCTAssertTrue([[url toUrl] isEqualToString:@"/unsafe/10x5/a.com/b.png"]);
    
    url = [_unsafe buildImage:@"b.com/c.png"];
    XCTAssertFalse(url.hasResize);
    
    url.resizeSize = ResizeSizeMake(THUMBOR_ORIGINAL_SIZE, THUMBOR_ORIGINAL_SIZE);
    XCTAssertTrue(url.hasResize);
    XCTAssertEqual(url.resizeSize.width, INT_MIN);
    XCTAssertEqual(url.resizeSize.height, INT_MIN);
    XCTAssertTrue([[url toUrl] isEqualToString:@"/unsafe/origxorig/b.com/c.png"]);
}

- (void)testResizeAndFitIn {
    OCThumborURLBuilder *url = [_unsafe buildImage:@"a.com/b.png"];
    url.resizeSize = ResizeSizeMake(10, 5);
    XCTAssertFalse(url.fitIn);
    url.fitIn = YES;
    XCTAssertTrue(url.fitIn);
    XCTAssertTrue([[url toUrl] isEqualToString:@"/unsafe/fit-in/10x5/a.com/b.png"]);
}

- (void)testResizeAndFlip {
    OCThumborURLBuilder *image1 = [_unsafe buildImage:@"a.com/b.png"];
    image1.resizeSize = ResizeSizeMake(10, 5);
    image1.flipHorizontally = YES;
    XCTAssertTrue(image1.flipHorizontally);
    XCTAssertTrue([[image1 toUrl] isEqualToString:@"/unsafe/-10x5/a.com/b.png"]);
    
    
    OCThumborURLBuilder *image2 = [_unsafe buildImage:@"a.com/b.png"];
    image2.resizeSize = ResizeSizeMake(10, 5);
    image2.flipVertically = YES;
    XCTAssertTrue(image2.flipVertically);
    XCTAssertTrue([[image2 toUrl] isEqualToString:@"/unsafe/10x-5/a.com/b.png"]);
    
    
    OCThumborURLBuilder *image3 = [_unsafe buildImage:@"a.com/b.png"];
    image3.resizeSize = ResizeSizeMake(10, 5);
    image3.flipHorizontally = YES;
    image3.flipVertically = YES;
    XCTAssertTrue(image3.flipHorizontally);
    XCTAssertTrue(image3.flipVertically);
    
    NSString *actual = [image3 toUrl];
    NSString *expected = @"/unsafe/-10x-5/a.com/b.png";
    XCTAssertTrue([actual isEqualToString:expected], @"Actual: %@ - Expected: %@", actual, expected);
}

- (void)testCrop {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"a.com/b.png"];
    XCTAssertFalse(image.hasCrop);
    image.cropEdgeInsets = CropEdgeInsetsMake(1, 2, 3, 4);
    XCTAssertTrue(image.hasCrop);
    XCTAssertEqual(image.cropEdgeInsets.top, 1);
    XCTAssertEqual(image.cropEdgeInsets.left, 2);
    XCTAssertEqual(image.cropEdgeInsets.bottom, 3);
    XCTAssertEqual(image.cropEdgeInsets.right, 4);
    XCTAssertTrue([[image toUrl] isEqualToString:@"/unsafe/2x1:4x3/a.com/b.png"]);
}

- (void)testCropAndSmart {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    image.cropEdgeInsets = CropEdgeInsetsMake(1, 2, 3, 4);
    XCTAssertFalse(image.smart);
    image.smart = YES;
    XCTAssertTrue(image.smart);
    
    NSString *actual = [image toUrl];
    NSString *expected = @"/unsafe/2x1:4x3/smart/http://a.com/b.png";
    XCTAssertTrue([actual isEqualToString:expected], @"Actual: %@ - Expected: %@", actual, expected);
}

- (void)testCannotFlipHorizontalWithoutResize {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.hasResize);
    XCTAssertFalse(image.flipHorizontally);
    
    XCTAssertThrows([image setFlipHorizontally:YES]);
    
    XCTAssertFalse(image.flipHorizontally);
}

- (void)testCannotFlipVerticalWithoutResize {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.hasResize);
    XCTAssertFalse(image.flipVertically);
    
    XCTAssertThrows([image setFlipVertically:YES]);
    
    XCTAssertFalse(image.flipVertically);
}

- (void)testCannotFitInWithoutCrop {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.hasCrop);
    XCTAssertFalse(image.fitIn);
    
    XCTAssertThrows([image setFitIn:YES]);
    
    XCTAssertFalse(image.fitIn);
}

- (void)testCannotSmartWithoutCrop {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.hasCrop);
    XCTAssertFalse(image.smart);
    
    XCTAssertThrows([image setSmart:YES]);
    
    XCTAssertFalse(image.smart);
}

- (void)testTrim {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.hasTrim);
    image.trimPixelColor = TrimPixelColorTopLeft;
    image.trimColorTolerance = 100;
    XCTAssertTrue(image.hasTrim);
    XCTAssertEqual(image.trimPixelColor, TrimPixelColorTopLeft);
    XCTAssertEqual(image.trimColorTolerance, 100);
    XCTAssertTrue([[image toUrl] isEqualToString:@"/unsafe/trim:top-left:100/http://a.com/b.png"]);
}

- (void)testCannotAlignWithoutCrop {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    XCTAssertFalse(image.hasCrop);
    XCTAssertEqual(image.cropHorizontalAlign, HorizontalAlignNone);
    XCTAssertEqual(image.cropVerticalAlign, VerticalAlignNone);
    
    XCTAssertThrows([image setCropHorizontalAlign:HorizontalAlignCenter], @"Allowed horizontal crop align without crop.");
    XCTAssertThrows([image setCropVerticalAlign:VerticalAlignMiddle], @"Allowed vertical crop align without crop.");
}

- (void)testCannotIssueBadCrop {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    
    XCTAssertThrows([image setCropEdgeInsets:CropEdgeInsetsMake(-1, 0, 1, 1)], @"Bad top value allowed.");
    XCTAssertThrows([image setCropEdgeInsets:CropEdgeInsetsMake(0, -1, 1, 1)], @"Bad left value allowed.");
    XCTAssertThrows([image setCropEdgeInsets:CropEdgeInsetsMake(0, 0, -1, 1)], @"Bad bottom value allowed.");
    XCTAssertThrows([image setCropEdgeInsets:CropEdgeInsetsMake(0, 0, 1, -1)], @"Bad right value allowed.");
    XCTAssertThrows([image setCropEdgeInsets:CropEdgeInsetsMake(0, 1, 1, 0)], @"Right value less than left value allowed.");
    XCTAssertThrows([image setCropEdgeInsets:CropEdgeInsetsMake(1, 0, 0, 1)], @"Bottom value less than top value allowed.");
}

- (void)testCannotIssueBadResize {
    OCThumborURLBuilder *image = [_unsafe buildImage:@"http://a.com/b.png"];
    
    XCTAssertThrows([image setResizeSize:ResizeSizeMake(-1, 5)], @"Bad width value allowed.");
    XCTAssertThrows([image setResizeSize:ResizeSizeMake(10, -400)], @"Bad height value allowed.");
    XCTAssertThrows([image setResizeSize:ResizeSizeMake(0, 0)], @"Zero resize value allowed.");
}

- (void)testCannotBuildSafeWithoutKey {
    XCTAssertThrows([[_unsafe buildImage:@"foo"] toUrlSafe], @"toUrlSafe succeeds without key.");
}

- (void)testFilterBrightnessInvalidValues {
    XCTAssertThrows(brightness(-101), @"Brightness allowed invalid value.");
    XCTAssertThrows(brightness(101), @"Brightness allowed invalid value.");
}

- (void)testFilterBrightnessFormat {
    XCTAssertTrue([brightness(30) isEqualToString:@"brightness(30)"]);
}

- (void)testFilterContrastInvalidValues {
    XCTAssertThrows(contrast(-101), @"Contrast allowed invalid value.");
    XCTAssertThrows(contrast(101), @"Contrast allowed invalid value.");
}

- (void)testFilterContrastFormat {
    XCTAssertTrue([contrast(30) isEqualToString:@"contrast(30)"]);
}

- (void)testFilterNoiseInvalidValues {
    XCTAssertThrows(noise(-1), @"Noise allowed invalid value.");
    XCTAssertThrows(noise(101), @"Noise allowed invalid value.");
}

- (void)testFilterNoiseFormat {
    XCTAssertTrue([noise(30) isEqualToString:@"noise(30)"]);
}

- (void)testFilterQualityInvalidValues {
    XCTAssertThrows(quality(-1), @"Quality allowed invalid value.");
    XCTAssertThrows(quality(101), @"Quality allowed invalid value.");
}

- (void)testFilterQualityFormat {
    XCTAssertTrue([quality(30) isEqualToString:@"quality(30)"]);
}

- (void)testFilterRgbInvalidValues {
    XCTAssertThrows(rgb(-101, 0, 0), @"RGB allowed invalid value.");
    XCTAssertThrows(rgb(0, -101, 0), @"RGB allowed invalid value.");
    XCTAssertThrows(rgb(0, 0, -101), @"RGB allowed invalid value.");
    XCTAssertThrows(rgb(101, 0, 0), @"RGB allowed invalid value.");
    XCTAssertThrows(rgb(0, 101, 0), @"RGB allowed invalid value.");
    XCTAssertThrows(rgb(0, 0, 101), @"RGB allowed invalid value.");
}

- (void)testFilterRgbFormat {
    XCTAssertTrue([rgb(-30, 40, -75) isEqualToString:@"rgb(-30,40,-75)"]);
}

- (void)testFilterRoundCornerInvalidValues {
    XCTAssertThrows(roundCorner(0), @"Round corner allowed invalid value.");
    XCTAssertThrows(roundCorner(-50), @"Round corner allowed invalid value.");
    XCTAssertThrows(roundCornerOC(1, -1, 0xFFFFFF), @"Round corner allowed invalid value.");
}

- (void)testFilterRoundCornerFormat {
    XCTAssertTrue([roundCorner(10) isEqualToString:@"round_corner(10,255,255,255)"]);
    XCTAssertTrue([roundCornerC(10, 0xFF1010) isEqualToString:@"round_corner(10,255,16,16)"]);
    XCTAssertTrue([roundCornerOC(10, 15, 0xFF1010) isEqualToString:@"round_corner(10|15,255,16,16)"]);
}

- (void)testFilterSharpenFormat {
    XCTAssertTrue([sharpen(3, 4, YES) isEqualToString:@"sharpen(3.0,4.0,true)"]);
    XCTAssertTrue([sharpen(3, 4, NO) isEqualToString:@"sharpen(3.0,4.0,false)"]);
    XCTAssertTrue([sharpen(3.1, 4.2, YES) isEqualToString:@"sharpen(3.1,4.2,true)"]);
    XCTAssertTrue([sharpen(3.1, 4.2, NO) isEqualToString:@"sharpen(3.1,4.2,false)"]);
}

- (void)testFilterFillingFormat {
    XCTAssertTrue([fill(0xFF2020) isEqualToString:@"fill(ff2020)"]);
    XCTAssertTrue([fill(0xABFF2020) isEqualToString:@"fill(ff2020)"]);
}

- (void)testFilterFrameFormat {
    XCTAssertTrue([frame(@"a.png") isEqualToString:@"frame(a.png)"]);
}

@end

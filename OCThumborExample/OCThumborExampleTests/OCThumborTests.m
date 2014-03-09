//
//  OCThumborExampleTests.m
//  OCThumborExampleTests
//
//  Created by Daniel Heckrath on 08.03.14.
//  Copyright (c) 2014 Codeserv. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCThumbor/OCThumbor.h>

@interface OCThumborTests : XCTestCase

@property (nonatomic, strong) OCThumbor *thumbor;

@end

NSString * const KEY = @"my-security-key";
NSString * const IMG = @"my.server.com/some/path/to/image.jpg";

@implementation OCThumborTests

- (void)testCannotAddInvalidKey {
    
    @try {
        [OCThumbor createWithHost:@"http://example.com" key:nil];
        XCTFail(@"Bad key string allowed.");
    } @catch (NSException *expected) {
    }
    
    @try {
        [OCThumbor createWithHost:@"http://example.com" key:@""];
        XCTFail(@"Bad key string allowed.");
    } @catch (NSException *expected) {
    }
}

- (void)testCannotAddInvalidHost {
    @try {
        [OCThumbor createWithHost:nil];
        XCTFail(@"Bad host string allowed.");
    } @catch (NSException *expected) {
    }
    
    @try {
        [OCThumbor createWithHost:@""];
        XCTFail(@"Bad host string allowed.");
    } @catch (NSException *expected) {
    }
}

- (void)testCannotBuildWithInvalidTarget {
    OCThumbor *thumbor = [OCThumbor createWithHost:@"http://example.com"];
    
    @try {
        [thumbor buildImage:nil];
        XCTFail(@"Bad target image URL allowed.");
    } @catch (NSException *expected) {
    }
    
    @try {
        [thumbor buildImage:@""];
        XCTFail(@"Bad target image URL allowed.");
    } @catch (NSException *expected) {
    }
}

- (void)testHostAlwaysEndsWithSlash {
    OCThumbor *t1 = [OCThumbor createWithHost:@"http://me.com/"];
    XCTAssertTrue([t1.host isEqualToString:@"http://me.com/"]);
    
    OCThumbor *t2 = [OCThumbor createWithHost:@"http://me.com"];
    XCTAssertTrue([t2.host isEqualToString:@"http://me.com/"]);
}

@end

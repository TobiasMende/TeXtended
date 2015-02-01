//
//  NSString_Categories_Test.m
//  TeXtended
//
//  Created by Tobias Mende on 16.03.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Kiwi.h"

#import <TMTHelperCollection/NSString+LatexExtension.h>
#import "NSString+PathExtension.h"
#import "NSString+RegexReplace.h"
#import "NSString+RNTextStatistics.h"
#import <TMTHelperCollection/NSString+TMTExtensions.h>

@interface NSString_Categories_Test : XCTestCase

@end

@implementation NSString_Categories_Test

#pragma mark - LatexExtension Tests

- (void)testIfLatexLineBreakPreceedsPosition
{
    NSString *mock = [NSString new];
    [mock stub:@selector(numberOfBackslashesBeforePosition:) andReturn:theValue(16) withArguments:theValue(99)];
    [mock stub:@selector(numberOfBackslashesBeforePositionIsEven:) andReturn:theValue(YES) withArguments:theValue(99)];
    
    
    BOOL result = [mock latexLineBreakPreceedingPosition:99];
    XCTAssertTrue(result);
    
    [mock stub:@selector(numberOfBackslashesBeforePositionIsEven:) andReturn:theValue(NO) withArguments:theValue(99)];
    XCTAssertFalse([mock latexLineBreakPreceedingPosition:99]);
    
    //[verify(mock) numberOfBackslashesBeforePositionIsEven:position];
    
    
}

- (void)testIfNumberOfSlashesBeforePositionIsEven {
    NSString *s1 = @"\\\\\\\n \\";
    XCTAssertTrue([s1 numberOfBackslashesBeforePositionIsEven:0]);
    XCTAssertTrue([s1 numberOfBackslashesBeforePositionIsEven:2]);
    XCTAssertTrue([s1 numberOfBackslashesBeforePositionIsEven:s1.length-1]);
    XCTAssertFalse([s1 numberOfBackslashesBeforePositionIsEven:s1.length]);
    
    NSString *s2 = @"alssldlasd asdasdlkasd dasdaskld \\ dasdlsldas asdhioasdlasd dskjda \\";
    XCTAssertFalse([s2 numberOfBackslashesBeforePositionIsEven:s2.length]);
    
}


- (void)testNumberOfSlashesBeforePositionIsCorrect {
    XCTAssertEqual([@"" numberOfBackslashesBeforePosition:0], 0);
    XCTAssertEqual([@" \\\\"numberOfBackslashesBeforePosition:2], 1);
    
    NSString *s1 = @"lsadlk sdjakjda adkaasdl sdjhasdkhjas \\\\";
    NSString *s2 = @"\\ladkllksdlasd asdkadkljasdlka dadkashkljda \\ ";
    NSString *total = [s1 stringByAppendingString:s2];
    
    XCTAssertEqual([total numberOfBackslashesBeforePosition:s1.length], 2);
    XCTAssertEqual([s2 numberOfBackslashesBeforePosition:s2.length], 0);
    XCTAssertEqual([s2 numberOfBackslashesBeforePosition:s2.length-1], 1);
    XCTAssertEqual([total numberOfBackslashesBeforePosition:s1.length+1], 3);
    
    NSString *slashesOnly = @"\\\\\\\\\\\\\\\\\\\\";
    for (int pos = 0; pos <= slashesOnly.length; pos++) {
        XCTAssertEqual([slashesOnly numberOfBackslashesBeforePosition:pos], pos);
    }
}

@end

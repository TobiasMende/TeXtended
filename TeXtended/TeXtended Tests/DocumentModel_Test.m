//
//  DocumentModel_Test.m
//  TeXtended
//
//  Created by Tobias Mende on 15.03.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DocumentModel.h"

DocumentModel *model;

@interface DocumentModel_Test : XCTestCase

@end

@implementation DocumentModel_Test

- (void)setUp
{
    [super setUp];
    model = [[DocumentModel alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLoadingFailsIfPathIsEmpty {
    
    XCTAssertNil([model loadContent:nil]);
    
    model.systemPath = @"";
    XCTAssertNil([model loadContent:nil]);
    
}

@end

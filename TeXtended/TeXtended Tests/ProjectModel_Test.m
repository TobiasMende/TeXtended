//
//  ProjectModel_Test.m
//  TeXtended
//
//  Created by Tobias Mende on 15.03.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ProjectModel.h"

ProjectModel *model;

@interface ProjectModel_Test : XCTestCase

@end

@implementation ProjectModel_Test

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    model = [[ProjectModel alloc] init];
}

- (void)testCollectionsOfNewProjectAreEmpty
{
    XCTAssertTrue(model.documents.count == 0, @"Documets of new project are not empty");
    XCTAssertTrue(model.bibFiles.count == 0, @"Bibfiles of new project are not empty");
}

- (void)testFolderPathIsNilIfProjectPathIsEmpty {
    XCTAssertNil(model.folderPath, @"FolderPath was supposed to be nil if project path is not set");
    
}

- (void)testFolderPathIsCorrect {
    model.path = @"Test/Bla/Project";
    XCTAssertEqualObjects(model.folderPath, @"Test/Bla");
    
    model.path = @"/Bla";
    XCTAssertEqualObjects(model.folderPath, @"/");
    
}

@end

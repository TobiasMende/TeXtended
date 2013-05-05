//
//  DocumentModel.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Compilable.h"

@class ProjectModel;

@interface DocumentModel : Compilable

@property (nonatomic, retain) NSDate * lastChanged;
@property (nonatomic, retain) NSDate * lastCompile;
@property (nonatomic, retain) NSString * pdfPath;
@property (nonatomic, retain) NSString * texPath;
@property (nonatomic, retain) NSNumber *encoding;
@property (nonatomic, retain) ProjectModel *project;

- (NSString*) loadContent;
- (BOOL) saveContent:(NSString*) content error:(NSError**) error;

@end

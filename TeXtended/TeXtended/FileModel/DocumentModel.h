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
@property (nonatomic, retain) NSSet *subCompilabels;

- (NSString*) loadContent;
- (BOOL) saveContent:(NSString*) content error:(NSError**) error;
@end

@interface DocumentModel (CoreDataGeneratedAccessors)

- (void)addSubCompilabelsObject:(Compilable *)value;
- (void)removeSubCompilabelsObject:(Compilable *)value;
- (void)addSubCompilabels:(NSSet *)values;
- (void)removeSubCompilabels:(NSSet *)values;


@end

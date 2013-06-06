//
//  ProjectModel.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Compilable.h"

@class BibFile, DocumentModel;

@interface ProjectModel : Compilable

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * path;
@property (nonatomic, strong) NSSet *bibFiles;
@property (nonatomic, strong) NSSet *documents;
@property (nonatomic, strong) DocumentModel *properties;

@end

@interface ProjectModel (CoreDataGeneratedAccessors)

- (void)addBibFilesObject:(BibFile *)value;
- (void)removeBibFilesObject:(BibFile *)value;
- (void)addBibFiles:(NSSet *)values;
- (void)removeBibFiles:(NSSet *)values;

- (void)addDocumentsObject:(DocumentModel *)value;
- (void)removeDocumentsObject:(DocumentModel *)value;
- (void)addDocuments:(NSSet *)values;
- (void)removeDocuments:(NSSet *)values;


@end

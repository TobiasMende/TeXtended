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

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSSet *bibFiles;
@property (nonatomic, retain) NSSet *documents;
@property (nonatomic, retain) NSSet *mainDocuments;
@property (nonatomic, retain) DocumentModel *properties;
@property (nonatomic, retain) DocumentModel *headerDocument;
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

- (void)addMainDocumentsObject:(DocumentModel *)value;
- (void)removeMainDocumentsObject:(DocumentModel *)value;
- (void)addMainDocuments:(NSSet *)values;
- (void)removeMainDocuments:(NSSet *)values;

@end

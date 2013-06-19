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


/**
 The ProjectModel is the representation of the core data object for a project.
 
 **Author:** Tobias Mende
 
 */
@interface ProjectModel : Compilable

/** The name of the project */
@property (nonatomic, strong) NSString * name;

/** The absolute path to the project file */
@property (nonatomic, strong) NSString * path;

/** A set of all bibFiles connected to this project */
@property (nonatomic, strong) NSSet *bibFiles;

/** A set of all documents belonging to this project */
@property (nonatomic, strong) NSSet *documents;

/** The main properties of this project */
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

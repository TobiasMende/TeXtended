//
//  Compilable.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Constants.h"

@class CompileSetting, DocumentModel, ProjectModel, BibFile, TMTBibTexEntry;

/**
 * Abstract parent class for ProjectModel and DocumentModel which combines similar properties of both subclasses.
 *
 * **Author:** Tobias Mende
 *
 */
@interface Compilable : NSObject <NSCoding>
    {

    }

#pragma mark - Properties

/** The NSTextEncoding of the file */
    @property (strong, nonatomic) NSNumber *encoding;

/** A set of mainDocuments that should be compiled instead of this compilabel itself */
    @property (nonatomic, strong) NSArray *mainDocuments;

/** A set of all bibFiles connected to this project */
    @property (strong) NSMutableArray *bibFiles;

    @property (readonly) NSString *identifier;


#pragma mark Compile Settings

/** The draft compile flow for this compilabel */
    @property (nonatomic, strong) CompileSetting *draftCompiler;

/** The final compile flow for this compilabel */
    @property (nonatomic, strong) CompileSetting *finalCompiler;

/** The live compile flow for this compilabel */
    @property (nonatomic, strong) CompileSetting *liveCompiler;


#pragma mark Flag Properties

    @property (nonatomic) BOOL hasLiveCompiler;

    @property (nonatomic) BOOL hasDraftCompiler;

    @property (nonatomic) BOOL hasFinalCompiler;


#pragma mark Getter & Setter

/**
 * Getter for the top most compilabel model. In case of a DocumentModel, this method returns the project if the model is part of a project or the DocumentModel itself otherwise.
 *
 * @return the main model of this Document
 */
    - (Compilable *)mainCompilable;

    - (ProjectModel *)project;

    - (NSDate *)lastChanged;

    - (NSDictionary *)fileSystemAttributes;

    - (NSString *)name;

    - (NSString *)path;

    - (NSString *)type;


#pragma mark - Collection Helpers
/**
 * In project mode, this method searches a appropriate DocumentModel for the given path and creates a new DocumentModel if no match was found. The new model is added to the projects documents set.
 *
 * @param path the absolute path to a to the tex document
 *
 * @return a matching document model.
 */
    - (DocumentModel *)modelForTexPath:(NSString *)path;

    - (DocumentModel *)modelForTexPath:(NSString *)path byCreating:(BOOL)shouldCreate;

    - (void)finishInitWithPath:(NSString *)absolutePath;

    - (void)updateCompileSettingBindings:(CompileMode)mode;


#pragma mark MainDocument Collection Helpers

    - (void)addMainDocument:(DocumentModel *)value;

    - (void)removeMainDocument:(DocumentModel *)value;

    - (void)addMainDocuments:(NSArray *)values;

    - (void)removeMainDocuments:(NSArray *)values;


#pragma mark BibFile Collection Helpers

    - (void)addBibFileWithPath:(NSString *)path;

    - (void)removeBibFileWithIndex:(NSUInteger)index;

    - (TMTBibTexEntry *)findBibTexEntryForKey:(NSString *)key containingDocument:(__autoreleasing NSString **)path;


@end
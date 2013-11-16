//
//  Compilable.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CompileSetting,DocumentModel;

/**
 Abstract parent class for ProjectModel and DocumentModel which combines similar properties of both subclasses.
 
 **Author:** Tobias Mende
 
 */
@interface Compilable : NSObject  {
    
}

/** The draft compile flow for this compilabel */
@property (nonatomic, strong) CompileSetting * draftCompiler;

/** The final compile flow for this compilabel */
@property (nonatomic, strong) CompileSetting * finalCompiler;

/** The live compile flow for this compilabel */
@property (nonatomic, strong) CompileSetting * liveCompiler;

/** The header document for this compilabel */
@property (strong) DocumentModel *headerDocument;

/** A set of mainDocuments that should be compiled instead of this compilabel itself */
@property (nonatomic, strong) NSMutableSet *mainDocuments;

/**
 Getter for the top most compilabel model. In case of a DocumentModel, this method returns the project if the model is part of a project or the DocumentModel itself otherwise.
 
 @return the main model of this Document
 */
- (Compilable*) mainCompilable;

/**
 In project mode, this method searches a appropriate DocumentModel for the given path and creates a new DocumentModel if no match was found. The new model is added to the projects documents set.
 
 @param path the absolute path to a to the tex document
 
 @return a matching document model.
 */
- (DocumentModel *) modelForTexPath:(NSString *)path;

- (DocumentModel *) modelForTexPath:(NSString *)path byCreating:(BOOL)shouldCreate;

/**
 Method for posting a notification to the notificatio center if this object might have any changes.
 
 */
- (void)postChangeNotification;

- (NSString*) dictionaryKey;
@end

@interface Compilable (CoreDataGeneratedAccessors)

- (void)addMainDocumentsObject:(DocumentModel *)value;
- (void)removeMainDocumentsObject:(DocumentModel *)value;
- (void)addMainDocuments:(NSSet *)values;
- (void)removeMainDocuments:(NSSet *)values;

@end


@interface Compilable (Getter)
- (NSString *) name;
- (NSString *) path;
- (NSString *) type;
- (NSString *) infoTitle;

@end
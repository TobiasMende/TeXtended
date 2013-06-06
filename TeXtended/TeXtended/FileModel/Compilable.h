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
@interface Compilable : NSManagedObject {
    
}

@property (nonatomic, strong) CompileSetting * draftCompiler;
@property (nonatomic, strong) CompileSetting * finalCompiler;
@property (nonatomic, strong) CompileSetting * liveCompiler;
@property (nonatomic, strong) DocumentModel *headerDocument;
@property (nonatomic, strong) NSSet *mainDocuments;

- (id) initWithContext:(NSManagedObjectContext*)context;

/**
 Getter for the top most compilabel model. In case of a DocumentModel, this method returns the project if the model is part of a project or the DocumentModel itself otherwise.
 
 @return the main model of this Document
 */
- (Compilable*) mainCompilable;
- (void)postChangeNotification;

@end

@interface Compilable (CoreDataGeneratedAccessors)

- (void)addMainDocumentsObject:(DocumentModel *)value;
- (void)removeMainDocumentsObject:(DocumentModel *)value;
- (void)addMainDocuments:(NSSet *)values;
- (void)removeMainDocuments:(NSSet *)values;

@end
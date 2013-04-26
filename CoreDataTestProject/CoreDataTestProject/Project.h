//
//  Project.h
//  CoreDataTestProject
//
//  Created by Tobias Mende on 26.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SimpleDocumentModel;

@interface Project : NSManagedObject

@property (nonatomic) NSTimeInterval lastOpened;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSManagedObject *bibCompiler;
@property (nonatomic, retain) NSSet *documents;
@property (nonatomic, retain) NSSet *mainDocuments;
@property (nonatomic, retain) SimpleDocumentModel *properties;
@property (nonatomic, retain) NSManagedObject *texCompiler;
@property (nonatomic, retain) NSManagedObject *typoCompiler;
@end

@interface Project (CoreDataGeneratedAccessors)

- (void)addDocumentsObject:(SimpleDocumentModel *)value;
- (void)removeDocumentsObject:(SimpleDocumentModel *)value;
- (void)addDocuments:(NSSet *)values;
- (void)removeDocuments:(NSSet *)values;

- (void)addMainDocumentsObject:(SimpleDocumentModel *)value;
- (void)removeMainDocumentsObject:(SimpleDocumentModel *)value;
- (void)addMainDocuments:(NSSet *)values;
- (void)removeMainDocuments:(NSSet *)values;

@end

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

@interface DocumentModel : Compilable {
    NSPipe *outputPipe, *inputPipe;
}

@property (nonatomic, strong) NSDate * lastChanged;
@property (nonatomic, strong) NSDate * lastCompile;
@property (nonatomic, strong) NSString * pdfPath;
@property (nonatomic, strong) NSString * texPath;
@property (nonatomic, strong) NSString * systemPath;
@property (nonatomic, strong) NSNumber *encoding;
@property (nonatomic, strong) ProjectModel *project;
@property (nonatomic, strong) NSSet *subCompilabels;

- (NSString*) loadContent;
- (BOOL) saveContent:(NSString*) content error:(NSError**) error;
- (NSString *)texName;

- (NSPipe*)outputPipe;
- (NSPipe*)inputPipe;
- (void)setOutputPipe:(NSPipe*)pipe;
- (void)setInputPipe:(NSPipe*)pipe;

@end

@interface DocumentModel (CoreDataGeneratedAccessors)

- (void)addSubCompilabelsObject:(Compilable *)value;
- (void)removeSubCompilabelsObject:(Compilable *)value;
- (void)addSubCompilabels:(NSSet *)values;
- (void)removeSubCompilabels:(NSSet *)values;
@end

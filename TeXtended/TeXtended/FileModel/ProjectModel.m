//
//  ProjectModel.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ProjectModel.h"
#import "BibFile.h"
#import "DocumentModel.h"
#import "Constants.h"
#import "CompileSetting.h"

@interface ProjectModel ()

/** Method for configuring the default settings of a project
 
 @param context the context.
 
 */
- (void)initDefaults:(NSManagedObjectContext*)context;
@end

@implementation ProjectModel

@dynamic name;
@dynamic path;
@dynamic bibFiles;
@dynamic documents;
@dynamic properties;

- (id)init {
    return nil;
}

- (id)initWithContext:(NSManagedObjectContext *)context {
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:context];
    self = [super initWithEntity:description insertIntoManagedObjectContext:context];
    if (self) {
        [self initDefaults:context];
    }
    return self;
}

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        [self initDefaults:context];
    }
    return self;
}

- (void)initDefaults:(NSManagedObjectContext *)context {
    if (!self.liveCompiler) {
        self.liveCompiler = [CompileSetting defaultLiveCompileSettingIn:context];
    }
    if (!self.draftCompiler) {
        self.draftCompiler = [CompileSetting defaultDraftCompileSettingIn:context];
    }
    if (!self.finalCompiler) {
        self.finalCompiler = [CompileSetting defaultFinalCompileSettingIn:context];
    }
    //FIME: Complete implementation
}



- (DocumentModel *)modelForTexPath:(NSString *)path byCreating:(BOOL)shouldCreate {
    for (DocumentModel *model in self.documents) {
        if ([model.texPath isEqualToString:path]) {
            return model;
        }
    }
    if (shouldCreate) {
        DocumentModel *model = [[DocumentModel alloc] initWithContext:self.managedObjectContext];
        [self addDocumentsObject:model];
        model.project = self;
        model.texPath = path;
        return model;
    } else {
        return nil;
    }
}

- (void)addBibFileWithPath:(NSString *)path {
    NSEntityDescription *description = [NSEntityDescription entityForName:@"BibFile" inManagedObjectContext:self.managedObjectContext];
    BibFile *file = [[BibFile alloc] initWithEntity:description insertIntoManagedObjectContext:self.managedObjectContext];
    file.path = path;
    file.project = self;
    [self addBibFilesObject:file];
}

- (NSString *)type {
    return NSLocalizedString(@"Project", @"Project");
}

- (NSString *)infoTitle {
    return NSLocalizedString(@"Project Information", @"Projectinformation");
}

- (void)setPath:(NSString *)path {
    NSString *old = [self primitiveValueForKey:@"path"];
    if (![old isEqualToString:path]) {
        [self internalSetValue:path forKey:@"path"];
    }
}

- (NSString *)folderPath {
    return [self.path stringByDeletingLastPathComponent];
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"folderPath"]) {
        keys = [keys setByAddingObject:@"path"];
    }
    
    return keys;
}

@end

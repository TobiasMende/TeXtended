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
- (void)initDefaults;
@end

@implementation ProjectModel

- (id)init {
    self = [super init];
    if (self) {
        [self initDefaults];
    }
    return self;
}

- (void)initDefaults {
    if (!self.liveCompiler) {
        self.liveCompiler = [CompileSetting defaultLiveCompileSetting];
    }
    if (!self.draftCompiler) {
        self.draftCompiler = [CompileSetting defaultDraftCompileSetting];
    }
    if (!self.finalCompiler) {
        self.finalCompiler = [CompileSetting defaultFinalCompileSetting];
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
        DocumentModel *model = [DocumentModel new];
        [self addDocumentsObject:model];
        model.project = self;
        model.texPath = path;
        return model;
    } else {
        return nil;
    }
}

- (void)addBibFileWithPath:(NSString *)path {
    BibFile *file = [BibFile new];
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
    if (![_path isEqualToString:path]) {
        _path = path;
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

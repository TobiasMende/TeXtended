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
#import "TMTLog.h"

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

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.documents = [aDecoder decodeObjectForKey:@"documents"];
        self.bibFiles = [aDecoder decodeObjectForKey:@"bibFiles"];
        self.properties = [aDecoder decodeObjectForKey:@"properties"];
        self.path = [aDecoder decodeObjectForKey:@"path"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.documents forKey:@"documents"];
    [aCoder encodeObject:self.bibFiles forKey:@"bibFiles"];
    [aCoder encodeObject:self.properties forKey:@"properties"];
    [aCoder encodeObject:self.path forKey:@"path"];
    [super encodeWithCoder:aCoder];
}


- (void)initDefaults {
    self.documents = [NSMutableSet new];
    self.bibFiles = [NSMutableSet new];
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
        [self.documents addObject:model];
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
    [self.bibFiles addObject:file];
}


# pragma mark - Getter & Setter

- (NSString *)name {
    return [self.path lastPathComponent];
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

- (ProjectModel *)project {
    return self;
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"folderPath"]) {
        keys = [keys setByAddingObject:@"path"];
    }
    
    return keys;
}

@end

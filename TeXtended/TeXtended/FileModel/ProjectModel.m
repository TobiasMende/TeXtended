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
#import "NSString+PathExtension.h"
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

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.path = [aDecoder decodeObjectForKey:@"path"];
        self.documents = [aDecoder decodeObjectForKey:@"documents"];
        self.bibFiles = [aDecoder decodeObjectForKey:@"bibFiles"];
        self.properties = [aDecoder decodeObjectForKey:@"properties"];
        [self initDefaults];
    }
    return self;
}

- (void)finishInitWithPath:(NSString *)absolutePath {
    self.path = absolutePath;
    for (DocumentModel * doc in self.documents) {
        [doc finishInitWithPath:absolutePath];
    }
}



- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    NSString *relativePath = [self.path relativePathWithBase:[self.path stringByDeletingLastPathComponent]];
    [aCoder encodeObject:relativePath forKey:@"path"];
    [aCoder encodeObject:self.documents forKey:@"documents"];
    [aCoder encodeObject:self.bibFiles forKey:@"bibFiles"];
    [aCoder encodeObject:self.properties forKey:@"properties"];
}


- (void)initDefaults {
    if (!self.documents) {
        self.documents = [NSMutableSet new];
    }
    if (!self.bibFiles) {
        self.bibFiles = [NSMutableSet new];
    }
    [self updateCompileSettingBindings:live];
    [self updateCompileSettingBindings:draft];
    [self updateCompileSettingBindings:final];
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

- (NSDate *)lastChanged {
    return nil;
}

- (NSDate *)lastCompile {
    return nil;
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

# pragma mark - KVO

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"folderPath"]) {
        keys = [keys setByAddingObject:@"path"];
    }
    
    return keys;
}

@end

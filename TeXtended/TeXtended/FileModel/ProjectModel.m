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
#import <TMTHelperCollection/TMTLog.h>
#import "NSString+PathExtension.h"
@interface ProjectModel ()

/** Method for configuring the default settings of a project
 
 @param context the context.
 
 */
- (void)initDefaults;

/** This method coverts bibfiles from older project versions from NSSet to NSArray */
- (NSMutableArray*)convertBibFiles:(id)bibfiles;
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
        
        self.bibFiles = [self convertBibFiles:[aDecoder decodeObjectForKey:@"bibFiles"]];
        self.properties = [aDecoder decodeObjectForKey:@"properties"];
        [self initDefaults];
    }
    return self;
}

- (NSMutableArray *)convertBibFiles:(id)bibfiles {
    if ([bibfiles isKindOfClass:[NSSet class]]) {
        NSMutableArray *finalBibfiles = [NSMutableArray arrayWithCapacity:[(NSSet *)bibfiles count]];
        for(id b in bibfiles) {
            [finalBibfiles addObject:b];
        }
        return finalBibfiles;
    } else {
        return bibfiles;
    }
}

- (void)finishInitWithPath:(NSString *)absolutePath {
    self.path = absolutePath;
    for (DocumentModel * doc in self.documents) {
        [doc finishInitWithPath:absolutePath];
    }
    
    [self.documents makeObjectsPerformSelector:@selector(buildOutline)];
    for (BibFile *f in self.bibFiles) {
        [f finishInitWithPath:absolutePath];
    }
}

- (void)updateCompileSettingBindings:(CompileMode)mode {
    [super updateCompileSettingBindings:mode];
    for(DocumentModel *doc in self.documents) {
        [doc updateCompileSettingBindings:mode];
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
        self.bibFiles = [NSMutableArray new];
    }
    [self updateCompileSettingBindings:live];
    [self updateCompileSettingBindings:draft];
    [self updateCompileSettingBindings:final];
    if (!self.encoding) {
        self.encoding = @(NSUTF8StringEncoding);
    }
}



- (DocumentModel *)modelForTexPath:(NSString *)path byCreating:(BOOL)shouldCreate {
    for (DocumentModel *model in self.documents) {
        if ([model.texPath isEqualToString:path]) {
            return model;
        }
    }
    if (shouldCreate) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return nil;
        }
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
    file.project = self;
    file.path = path;
    [self willChangeValueForKey:@"bibFiles"];
    [self.bibFiles addObject:file];
    [self didChangeValueForKey:@"bibFiles"];
}

- (void) removeBibFileWithIndex:(NSUInteger)index {
    [self willChangeValueForKey:@"bibFiles"];
    [self.bibFiles removeObjectAtIndex:index];
    [self didChangeValueForKey:@"bibFiles"];
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


- (void)dealloc {
    DDLogVerbose(@"dealloc");
    for (DocumentModel *d in self.documents) {
        d.project = nil;
    }
    self.properties.project = nil;
    for (BibFile *d in self.bibFiles) {
        d.project = nil;
    }
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

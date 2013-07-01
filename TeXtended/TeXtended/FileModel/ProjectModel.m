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


- (id)initWithContext:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
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


- (DocumentModel *)modelForTexPath:(NSString *)path {
    for (DocumentModel *model in self.documents) {
        if ([model.texPath isEqualToString:path]) {
            return model;
        }
    }
    DocumentModel *model = [[DocumentModel alloc] initWithContext:self.managedObjectContext];
    model.texPath = path;
    [self addDocumentsObject:model];
    return model;
}

- (NSString *)type {
    return NSLocalizedString(@"Project", @"Project");
}

- (NSString *)infoTitle {
    return NSLocalizedString(@"Projectinformation", @"Projectinformation");
}

- (void)setPath:(NSString *)path {
    NSString *old = [self primitiveValueForKey:@"path"];
    if (![old isEqualToString:path]) {
        [self internalSetValue:path forKey:@"path"];
    }
}

@end

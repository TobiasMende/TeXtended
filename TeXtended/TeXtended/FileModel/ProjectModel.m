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

@end

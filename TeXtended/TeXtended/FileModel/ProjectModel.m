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

static NSArray *TMTLiveCompileSettingKeys, *TMTDraftCompileSettingKeys, *TMTFinalCompileSettingKeys;
@interface ProjectModel ()
- (void) registerCompilerDefaultsObserver:(NSArray*)keys check:(CompileSetting*)setting;
- (void) unregisterCompilerDefaultsObserver:(NSArray*)keys check:(CompileSetting*)setting;
@end

@implementation ProjectModel

@dynamic name;
@dynamic path;
@dynamic bibFiles;
@dynamic documents;
@dynamic properties;


+ (void)initialize {
    TMTLiveCompileSettingKeys = [NSArray arrayWithObjects:TMTLiveCompileArgs,TMTLiveCompileBib,TMTLiveCompileFlow, TMTLiveCompileIterations, nil];
    TMTDraftCompileSettingKeys = [NSArray arrayWithObjects:TMTDraftCompileArgs,TMTDraftCompileBib,TMTDraftCompileFlow, TMTDraftCompileIterations, nil];
    TMTFinalCompileSettingKeys = [NSArray arrayWithObjects:TMTFinalCompileArgs,TMTFinalCompileBib,TMTFinalCompileFlow, TMTFinalCompileIterations, nil];
}


- (id)initWithContext:(NSManagedObjectContext *)context {
    self = [super initWithContext:context];
    if (self) {
        [self registerCompilerDefaultsObserver:TMTLiveCompileSettingKeys check:self.liveCompiler];
        [self registerCompilerDefaultsObserver:TMTDraftCompileSettingKeys check:self.draftCompiler];
        [self registerCompilerDefaultsObserver:TMTFinalCompileSettingKeys check:self.finalCompiler];
    }
    return self;
}


#pragma mark -
#pragma mark Getter & Setter

- (void)setDraftCompiler:(CompileSetting *)draftCompiler {
    [self unregisterCompilerDefaultsObserver:TMTDraftCompileSettingKeys check:self.draftCompiler];
    [self willChangeValueForKey:@"draftCompiler"];
    [self setPrimitiveValue:draftCompiler forKey:@"draftCompiler"];
    [self didChangeValueForKey:@"draftCompiler"];
    [self registerCompilerDefaultsObserver:TMTDraftCompileSettingKeys check:self.draftCompiler];
}

- (void)setLiveCompiler:(CompileSetting *)liveCompiler {
    [self unregisterCompilerDefaultsObserver:TMTLiveCompileSettingKeys check:self.liveCompiler];
    [self willChangeValueForKey:@"liveCompiler"];
    [self setPrimitiveValue:liveCompiler forKey:@"liveCompiler"];
    [self didChangeValueForKey:@"liveCompiler"];
    [self registerCompilerDefaultsObserver:TMTLiveCompileSettingKeys check:self.liveCompiler];
}

- (void)setFinalCompiler:(CompileSetting *)finalCompiler {
    [self unregisterCompilerDefaultsObserver:TMTFinalCompileSettingKeys check:self.finalCompiler];
    [self willChangeValueForKey:@"finalCompiler"];
    [self setPrimitiveValue:finalCompiler forKey:@"finalCompiler"];
    [self didChangeValueForKey:@"finalCompiler"];
    [self registerCompilerDefaultsObserver:TMTFinalCompileSettingKeys check:self.finalCompiler];
}


#pragma mark -
#pragma mark Register & unregister defaults observer
- (void)registerCompilerDefaultsObserver:(NSArray *)keys check:(CompileSetting *)setting {
    if (setting) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *key in keys) {
        [defaults addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
}

- (void)unregisterCompilerDefaultsObserver:(NSArray *)keys check:(CompileSetting *)setting {
    if (!setting) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *key in keys) {
        [defaults removeObserver:self forKeyPath:key];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([TMTLiveCompileSettingKeys containsObject:keyPath]) {
        [self didChangeValueForKey:@"liveCompiler"];
    } else if([TMTDraftCompileSettingKeys containsObject:keyPath]) {
        [self didChangeValueForKey:@"draftCompiler"];
    } else if([TMTDraftCompileSettingKeys containsObject:keyPath]) {
        [self didChangeValueForKey:@"finalCompiler"];
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end

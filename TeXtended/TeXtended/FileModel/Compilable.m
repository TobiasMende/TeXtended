//
//  Compilable.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Compilable.h"
#import "CompileSetting.h"
#import "Constants.h"

static NSArray *TMTLiveCompileSettingKeys, *TMTDraftCompileSettingKeys, *TMTFinalCompileSettingKeys;


@interface Compilable ()
- (void) registerCompilerDefaultsObserver:(NSArray*)keys check:(CompileSetting*)setting;
- (void) unregisterCompilerDefaultsObserver:(NSArray*)keys check:(CompileSetting*)setting;
- (void) initDefaults;
@end

@implementation Compilable

@dynamic draftCompiler;
@dynamic finalCompiler;
@dynamic liveCompiler;
@dynamic headerDocument;
@dynamic mainDocuments;

+ (void)initialize {
    TMTLiveCompileSettingKeys = [NSArray arrayWithObjects:TMTLiveCompileArgs,TMTLiveCompileBib,TMTLiveCompileFlow, TMTLiveCompileIterations, nil];
    TMTDraftCompileSettingKeys = [NSArray arrayWithObjects:TMTDraftCompileArgs,TMTDraftCompileBib,TMTDraftCompileFlow, TMTDraftCompileIterations, nil];
    TMTFinalCompileSettingKeys = [NSArray arrayWithObjects:TMTFinalCompileArgs,TMTFinalCompileBib,TMTFinalCompileFlow, TMTFinalCompileIterations, nil];
}

- (id)initWithContext:(NSManagedObjectContext *)context {
    NSEntityDescription *description = [NSEntityDescription entityForName:@"CompileSetting" inManagedObjectContext:context];
    self = [super initWithEntity:description insertIntoManagedObjectContext:context];
    if (self) {
        [self initDefaults];
    }
    return self;
}

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
        if (self) {
            [self initDefaults];
        }
    return self;
}

- (void)initDefaults {
    [self registerCompilerDefaultsObserver:TMTLiveCompileSettingKeys check:self.liveCompiler];
    [self registerCompilerDefaultsObserver:TMTDraftCompileSettingKeys check:self.draftCompiler];
    [self registerCompilerDefaultsObserver:TMTFinalCompileSettingKeys check:self.finalCompiler];
}



#pragma mark -
#pragma mark Getter & Setter

- (Compilable *)mainCompilable {
    return self;
}

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


- (CompileSetting *)draftCompiler {
    [self willAccessValueForKey:@"draftCompiler"];
    CompileSetting *setting = [self primitiveValueForKey:@"draftCompiler"];
    [self didAccessValueForKey:@"draftCompiler"];
    if (setting) {
        return setting;
    }
    return [CompileSetting defaultDraftCompileSettingIn:[self managedObjectContext]];
}

- (CompileSetting *)finalCompiler {
    [self willAccessValueForKey:@"finalCompiler"];
    CompileSetting *setting = [self primitiveValueForKey:@"finalCompiler"];
    [self didAccessValueForKey:@"finalCompiler"];
    if (setting) {
        return setting;
    }
    return [CompileSetting defaultFinalCompileSettingIn:[self managedObjectContext]];
}

- (CompileSetting *)liveCompiler {
    [self willAccessValueForKey:@"liveCompiler"];
    CompileSetting *setting = [self primitiveValueForKey:@"liveCompiler"];
    [self didAccessValueForKey:@"liveCompiler"];
    if (setting) {
        return setting;
    }
    return [CompileSetting defaultDraftCompileSettingIn:[self managedObjectContext]];
}


#pragma mark -
#pragma mark KVO & Notifications
- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    [self postChangeNotification];
    
}

- (void)postChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:TMTDocumentModelDidChangeNotification object:self];
}

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

//- (void)willTurnIntoFault {
//    [self unregisterCompilerDefaultsObserver:TMTLiveCompileSettingKeys check:self.liveCompiler];
//    [self unregisterCompilerDefaultsObserver:TMTDraftCompileSettingKeys check:self.draftCompiler];
//    [self unregisterCompilerDefaultsObserver:TMTFinalCompileSettingKeys check:self.finalCompiler];
//}

@end

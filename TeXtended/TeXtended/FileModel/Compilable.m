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
#import "TMTLog.h"
#import "TMTNotificationCenter.h"

static const NSSet *COMPILER_NAMES;

@interface Compilable ()
- (void) initDefaults;
@end

@implementation Compilable

@dynamic draftCompiler;
@dynamic finalCompiler;
@dynamic liveCompiler;
@dynamic headerDocument;
@dynamic mainDocuments;

+ (void)initialize {
    COMPILER_NAMES = [NSSet setWithObjects:@"draftCompiler", @"finalCompiler", @"liveCompiler", nil];
}

- (id)initWithContext:(NSManagedObjectContext *)context {
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Compilable" inManagedObjectContext:context];
    self = [super initWithEntity:description insertIntoManagedObjectContext:context];
    if (self) {
        [self initDefaults];
    }
    return self;
}

- (NSString *)dictionaryKey {
    return [[[self objectID] URIRepresentation] absoluteString];
}

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
        if (self) {
            [self initDefaults];
        }
    return self;
}

- (void)initDefaults {
    
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    NSArray *components = [keyPath componentsSeparatedByString:@"."];
    NSString *dest = [components objectAtIndex:0];
    if ([components count] > 1 && [COMPILER_NAMES containsObject:dest]) {
        CompileSetting *setting = (CompileSetting*)[self valueForKey:dest];
        [setting unbindAll];
        NSMutableArray *mutable = [NSMutableArray arrayWithArray:components];
        [mutable removeObjectAtIndex:0];
         [setting setValue:value forKeyPath:[mutable componentsJoinedByString:@"."]];
    } else {
        [super setValue:value forKeyPath:keyPath];
    }
}


- (void) internalSetValue:(id)value forKey:(NSString *)key {
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:value forKey:key];
    [self didChangeValueForKey:key];
}

#pragma mark -
#pragma mark Getter & Setter

- (Compilable *)mainCompilable {
    return self;
}

- (DocumentModel *)modelForTexPath:(NSString *)path {
    [self modelForTexPath:path byCreating:YES];
}

- (DocumentModel *)modelForTexPath:(NSString *)path byCreating:(BOOL)shouldCreate {
    DDLogError(@"This is not my job. Ask ProjectModel or DocumentModel instead.");
    return nil;
}


#pragma mark -
#pragma mark KVO & Notifications
- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    [self postChangeNotification];
    
}

- (void)postChangeNotification {
    [[TMTNotificationCenter centerForCompilable:self] postNotificationName:TMTDocumentModelDidChangeNotification object:self];
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


//- (void)willTurnIntoFault {
//    [self unregisterCompilerDefaultsObserver:TMTLiveCompileSettingKeys check:self.liveCompiler];
//    [self unregisterCompilerDefaultsObserver:TMTDraftCompileSettingKeys check:self.draftCompiler];
//    [self unregisterCompilerDefaultsObserver:TMTFinalCompileSettingKeys check:self.finalCompiler];
//}


@end

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


+ (void)initialize {
    COMPILER_NAMES = [NSSet setWithObjects:@"draftCompiler", @"finalCompiler", @"liveCompiler", nil];
}

- (id)init {
    self = [super init];
    if (self) {
        [self initDefaults];
    }
    return self;
}

- (NSString *)dictionaryKey {
    return [NSString stringWithFormat:@"%ld", self.hash];
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




#pragma mark -
#pragma mark Getter & Setter

- (Compilable *)mainCompilable {
    return self;
}

- (DocumentModel *)modelForTexPath:(NSString *)path {
    return [self modelForTexPath:path byCreating:YES];
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


- (void)dealloc {
    if (self == self.mainCompilable) {
        [TMTNotificationCenter removeCenterForCompilable:self];
    }
}

@end

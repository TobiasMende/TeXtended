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
@end

@implementation Compilable


+ (void)initialize {
    COMPILER_NAMES = [NSSet setWithObjects:@"draftCompiler", @"finalCompiler", @"liveCompiler", nil];
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.draftCompiler = [aDecoder decodeObjectForKey:@"draftCompiler"];
        self.finalCompiler = [aDecoder decodeObjectForKey:@"finalCompiler"];
        self.liveCompiler = [aDecoder decodeObjectForKey:@"liveCompiler"];
        NSSet *mainDocuments =[aDecoder decodeObjectForKey:@"mainDocuments"];
        if (mainDocuments) {
            @try {
                if (mainDocuments.count > 0) {
                    self.mainDocuments = mainDocuments;
                }
            }
            @catch (NSException *exception) {
                DDLogVerbose(@"Invalid mainDocuments set. Exception: %@", exception);
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.draftCompiler forKey:@"draftCompiler"];
    [aCoder encodeObject:self.finalCompiler forKey:@"finalCompiler"];
    [aCoder encodeObject:self.liveCompiler forKey:@"liveCompiler"];
    [aCoder encodeObject:self.mainDocuments forKey:@"mainDocuments"];
}

- (NSString *)dictionaryKey {
    return [NSString stringWithFormat:@"%ld", self.hash];
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

- (ProjectModel *)project {
    return nil;
}

- (void)addMainDocuments:(NSSet *)values {
    if (!self.mainDocuments) {
        self.mainDocuments = [NSSet new];
    }
    self.mainDocuments = [self.mainDocuments setByAddingObjectsFromSet:values];
}

- (void)removeMainDocuments:(NSSet *)values {
    NSMutableSet *tmp = [self.mainDocuments mutableCopy];
    for(NSObject *obj in values) {
        [tmp removeObject:obj];
    }
    self.mainDocuments = tmp;
}

- (void)removeMainDocumentsObject:(DocumentModel *)value {
    NSMutableSet *tmp = [self.mainDocuments mutableCopy];
    [tmp removeObject:value];
    self.mainDocuments = tmp;
}

- (void)addMainDocumentsObject:(DocumentModel *)value {
    if (!self.mainDocuments) {
         self.mainDocuments = [NSSet new];
    }
    self.mainDocuments = [self.mainDocuments setByAddingObject:value];
}

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

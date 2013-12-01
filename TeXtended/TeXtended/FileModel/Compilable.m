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


@interface Compilable ()
@end

@implementation Compilable


#pragma mark - Initialization
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
        
        self.hasFinalCompiler = self.finalCompiler != nil;
        self.hasDraftCompiler = self.draftCompiler != nil;
        self.hasLiveCompiler = self.liveCompiler != nil;
        
            @try {
                NSSet *mainDocuments =[aDecoder decodeObjectForKey:@"mainDocuments"];
                if (mainDocuments && mainDocuments.count > 0) {
                    self.mainDocuments = mainDocuments;
                }
            }
            @catch (NSException *exception) {
                DDLogVerbose(@"Invalid mainDocuments set. Exception: %@", exception);
            }
    }
    return self;
}

- (void)finishInitWithPath:(NSString *)absolutePath {}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (self.draftCompiler) {
        [aCoder encodeObject:self.draftCompiler forKey:@"draftCompiler"];
    }
    if (self.liveCompiler) {
        [aCoder encodeObject:self.liveCompiler forKey:@"liveCompiler"];
    }
    if (self.finalCompiler) {
        [aCoder encodeObject:self.finalCompiler forKey:@"finalCompiler"];
    }
    [aCoder encodeObject:_mainDocuments forKey:@"mainDocuments"];
}

- (NSString *)dictionaryKey {
    return [NSString stringWithFormat:@"%ld", self.hash];
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


#pragma mark Compile Setting Handling

- (void)updateCompileSettingBindings:(CompileMode)mode {
    switch (mode) {
        case live:
        if (self.hasLiveCompiler) {
            [self.liveCompiler unbindAll];
        } else {
            self.liveCompiler = [CompileSetting defaultLiveCompileSetting];
        }
        break;
        case draft:
        if (self.hasDraftCompiler) {
            [self.draftCompiler unbindAll];
        } else {
            self.draftCompiler = [CompileSetting defaultDraftCompileSetting];
        }
        break;
        case final:
        if (self.hasFinalCompiler) {
            [self.finalCompiler unbindAll];
        } else {
            self.finalCompiler = [CompileSetting defaultFinalCompileSetting];
        }
        break;
        default:
        break;
    }
}

- (void)setHasLiveCompiler:(BOOL)hasLiveCompiler {
    if (hasLiveCompiler != _hasLiveCompiler) {
        _hasLiveCompiler = hasLiveCompiler;
        [self updateCompileSettingBindings:live];
    }
}

- (void)setHasDraftCompiler:(BOOL)hasDraftCompiler {
    if (hasDraftCompiler != _hasDraftCompiler) {
        _hasDraftCompiler = hasDraftCompiler;
        [self updateCompileSettingBindings:draft];
    }
}

- (void)setHasFinalCompiler:(BOOL)hasFinalCompiler {
    if (hasFinalCompiler != _hasFinalCompiler) {
        _hasFinalCompiler = hasFinalCompiler;
        [self updateCompileSettingBindings:final];
    }
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

- (void)dealloc {
    if (self == self.mainCompilable) {
        [TMTNotificationCenter removeCenterForCompilable:self];
    }
}

@end

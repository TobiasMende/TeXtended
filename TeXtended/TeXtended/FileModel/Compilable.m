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

@implementation Compilable

@dynamic draftCompiler;
@dynamic finalCompiler;
@dynamic liveCompiler;
@dynamic headerDocument;
@dynamic mainDocuments;

- (id)initWithContext:(NSManagedObjectContext *)context {
    return [super init];
}

- (Compilable *)mainCompilable {
    return self;
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    [self postChangeNotification];
    
}

- (void)postChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:TMTDocumentModelDidChangeNotification object:self];
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

@end

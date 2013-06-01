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
    NSLog(@"Did change: %@", key );
    
    [self postChangeNotification];
    
}

- (void)postChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:TMTDocumentModelDidChangeNotification object:self];
}

@end

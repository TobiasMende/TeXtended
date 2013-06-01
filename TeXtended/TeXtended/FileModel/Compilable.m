//
//  Compilable.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Compilable.h"
#import "CompileSetting.h"

@implementation Compilable

@dynamic draftCompiler;
@dynamic finalCompiler;
@dynamic liveCompiler;

- (id)initWithContext:(NSManagedObjectContext *)context {
    return [super init];
}

- (Compilable *)mainCompilable {
    return self;
}

@end

//
//  CompileFlowHandler.m
//  TeXtended
//
//  Created by Tobias Mende on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompileFlowHandler.h"
#import "ApplicationController.h"
static CompileFlowHandler* instance;
@implementation CompileFlowHandler

- (id)init {
    if (!instance) {
        self = [super init];
        return self;
    }
    return instance;
}

+ (CompileFlowHandler *)sharedInstance {
    if(!instance) {
        instance = [[CompileFlowHandler alloc] init];
    }
    return instance;
}

- (NSArray *)flows {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    
    NSString* appSupport = [ApplicationController userApplicationSupportDirectoryPath];
    NSString* flowPath = [appSupport stringByAppendingPathComponent:@"/flows/"];
    
    NSArray* flowPaths = [fm contentsOfDirectoryAtPath:flowPath error:&error];
    
    if (error) {
        NSLog(@"Can't read flows from %@. Error: %@", flowPath, [error userInfo]);
        return nil;
    }
    return flowPaths;
    
}
@end

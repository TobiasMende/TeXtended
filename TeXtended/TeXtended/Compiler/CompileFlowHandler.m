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
    
    NSString* flowPath = [CompileFlowHandler path];
    
    NSArray* flowPaths = [fm contentsOfDirectoryAtURL:[NSURL fileURLWithPath:flowPath] includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLPathKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
    
    NSMutableArray *final = [[NSMutableArray alloc] initWithCapacity:[flowPaths count]];
    for(NSString *p in flowPaths) {
        //NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:p,@"path", [p lastPathComponent],@"title", nil];
        NSString *d = [p lastPathComponent];
        [final addObject:d];
    }
    
    if (error) {
        NSLog(@"Can't read flows from %@. Error: %@", flowPath, [error userInfo]);
        return nil;
    }
    return final;
    
}

- (id)arrangedObjects {
    return [self flows];
}

+(NSString *)path {
    return [[ApplicationController userApplicationSupportDirectoryPath] stringByAppendingPathComponent:@"/flows/"];
}
@end

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
        if (self) {
            _maxIterations = [NSNumber numberWithInt:3];
            _minIterations = [NSNumber numberWithInt:1];
        }
        instance = self;
    }
    return instance;
}

+ (CompileFlowHandler *)sharedInstance {
    CompileFlowHandler *tmp = instance;
    if(!tmp) {
        tmp =[[CompileFlowHandler alloc] init];
    }
    return tmp;
}

- (NSArray *)flows {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    
    NSString* flowPath = [CompileFlowHandler path];
    
    NSArray* flowPaths = [fm contentsOfDirectoryAtURL:[NSURL fileURLWithPath:flowPath] includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLPathKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init]; [dict setObject:[NSNumber numberWithInt:511] forKey:NSFilePosixPermissions];
    
    NSMutableArray *final = [[NSMutableArray alloc] initWithCapacity:[flowPaths count]];
    for(NSURL *p in flowPaths) {
        //NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:p,@"path", [p lastPathComponent],@"title", nil];
        NSError *error1;
            [fm setAttributes:dict ofItemAtPath:[p path] error:&error1];
            if (error1) {
                NSLog(@"Can't set permission for %@. Error: %@",p,[error1 userInfo]);
            }
        
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
    NSString *dir =[[ApplicationController userApplicationSupportDirectoryPath] stringByAppendingPathComponent:@"/flows/"];
    return dir;
}
@end

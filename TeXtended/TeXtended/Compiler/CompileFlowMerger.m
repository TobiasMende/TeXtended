//
// Created by Tobias Mende on 25.10.15.
// Copyright (c) 2015 Tobias Mende. All rights reserved.
//

#import "CompileFlowMerger.h"

#import "CompileFlowHandler.h"
#import "PathFactory.h"

#import <TMTHelperCollection/TMTLog.h>

LOGGING_DEFAULT

@interface CompileFlowMerger ()
    - (NSArray *)compileFlows;
    - (void)copyCompileFlows:(bool)force;
@end

@implementation CompileFlowMerger {
    NSFileManager *fileManager;
    NSString* flowPath;
    NSString* bundlePath;
}

- (id)init {
    self = [super init];
    if(self) {
        fileManager = [NSFileManager defaultManager];
        flowPath = [CompileFlowHandler path];
        bundlePath = [[NSBundle mainBundle] pathForResource:@"CompileFlows" ofType:nil];
    }
    return self;
}

- (void)mergeCompileFlows:(bool)force {
    BOOL exists = [PathFactory checkForAndCreateFolder:flowPath];
    if (exists) {
        [self copyCompileFlows:force];
    }
}

- (void)copyCompileFlows:(bool)force {
    NSArray *compileFlows = [self compileFlows];
    for (NSString* path in compileFlows) {
        NSString* srcPath = [bundlePath stringByAppendingPathComponent:path];
        NSString* destPath = [flowPath stringByAppendingPathComponent:path];
        if (force && [fileManager fileExistsAtPath:destPath]) {
            [self removeFile:destPath];
        }
        [self copyFile:srcPath to:destPath];
    }
}

- (void)removeFile:(NSString *)destPath {
    NSError* replaceError;
    [fileManager removeItemAtPath:destPath error:&replaceError];
    if (replaceError) {
        DDLogError(@"Can't remove file %@: %@ (%li)", destPath, replaceError.userInfo, replaceError.code);
    }
}

- (void)copyFile:(NSString *)srcPath to:(NSString *)destPath {
    NSError* copyError;
    [fileManager copyItemAtPath:srcPath toPath:destPath error:&copyError];
    if (copyError) {
        NSError * underlying = [[copyError userInfo] valueForKey:NSUnderlyingErrorKey];
        if (underlying && [underlying code] != 17) {
            DDLogError(@"Can't merge flow %@:\t %@", srcPath, [copyError userInfo]);
        }
    } else {
        [self updateFileAttributes:destPath];
    }
}

- (void)updateFileAttributes:(NSString *)destPath {
    NSDictionary* fileAttributes = @{NSFilePosixPermissions : @511};
    NSError* error;
    [fileManager setAttributes:fileAttributes ofItemAtPath:destPath error:&error];
    if (error) {
        DDLogError(@"Error while setting permission: %@", [error userInfo]);
    }
}

- (NSArray *)compileFlows {
    NSError* error;
    NSArray *compileFlows = [fileManager contentsOfDirectoryAtPath:bundlePath error:&error];
    if(error) {
        DDLogError(@"Can't read compile flows from %@. Error: %@", bundlePath, [error userInfo]);
    }
    return compileFlows;
}

@end
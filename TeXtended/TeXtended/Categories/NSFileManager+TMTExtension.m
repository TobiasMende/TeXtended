//
//  NSFileManager+DirectoryExtension.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSFileManager+TMTExtension.h"
#import "Constants.h"

@implementation NSFileManager (TMTExtension)


    - (BOOL)directoryExistsAtPath:(NSString *)path
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDirectory;
        BOOL fileExists = [fm fileExistsAtPath:path isDirectory:&isDirectory];
        return isDirectory && fileExists;
    }

    - (BOOL)removeTemporaryFilesAtPath:(NSString *)directory
    {
        NSArray *children = [self contentsOfDirectoryAtPath:directory error:nil];
        if (!children) {
            return NO;
        }
        BOOL success = YES;
        for (NSString *path in children) {
            if ([[NSFileManager temporaryFileExtensions] containsObject:path.pathExtension.lowercaseString] && ![self directoryExistsAtPath:[directory stringByAppendingPathComponent:path]]) {
                success &= [self removeItemAtPath:[directory stringByAppendingPathComponent:path] error:nil];
            }
        }
        return success;
    }

    + (const NSArray *)temporaryFileExtensions
    {
        NSArray *extensions = [[NSUserDefaults standardUserDefaults] arrayForKey:TMTTemporaryFileExtensions];
        NSMutableArray *final = [NSMutableArray arrayWithCapacity:extensions.count];
        for (NSString *val in extensions) {
            [final addObject:val.lowercaseString];
        }
        return final;
    }
@end

//
//  NSFileManager+DirectoryExtension.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSFileManager+TMTExtension.h"

static const NSArray *TEMP_FILE_EXTENSIONS;

@implementation NSFileManager (TMTExtension)


    + (void)initialize
    {
        if ([self class] == [NSFileManager class]) {
            TEMP_FILE_EXTENSIONS = @[@"aux", @"synctex", @"gz", @"gz(busy)", @"log", @"bbl"];
        }
    }

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
            if ([TEMP_FILE_EXTENSIONS containsObject:path.pathExtension.lowercaseString] && ![self directoryExistsAtPath:[directory stringByAppendingPathComponent:path]]) {
                success &= [self removeItemAtPath:[directory stringByAppendingPathComponent:path] error:nil];
            }
        }
        return success;
    }

    + (const NSArray *)temporaryFileExtensions
    {
        return TEMP_FILE_EXTENSIONS;
    }
@end

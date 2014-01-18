//
//  NSFileManager+DirectoryExtension.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "NSFileManager+DirectoryExtension.h"

@implementation NSFileManager (DirectoryExtension)


- (BOOL)directoryExistsAtPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL fileExists = [fm fileExistsAtPath:path isDirectory:&isDirectory];
    return isDirectory && fileExists;
}
@end

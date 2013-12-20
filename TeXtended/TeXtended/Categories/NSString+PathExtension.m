//
//  NSString+PathExtension.m
//  TeXtended
//
//  Created by Tobias Mende on 02.08.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "NSString+PathExtension.h"

@implementation NSString (PathExtension)
- (NSString*)relativePathWithBase:(NSString*)basePath {
    basePath = [[NSURL fileURLWithPath:basePath] path];
    NSArray* absoluteComps = [self pathComponents];
    NSArray* baseComps = [basePath pathComponents];
    NSUInteger ai = 0;
    NSUInteger bi = 0;
    while (ai < absoluteComps.count && bi < baseComps.count) {
        if ([absoluteComps[ai] isEqualToString:baseComps[bi]]) {
            ai++;
            bi++;
        } else {
            break;
        }
    }
    NSString *finalPath = @"";
    if (bi < baseComps.count) {
        for (; bi < baseComps.count; bi++) {
            finalPath = [finalPath stringByAppendingPathComponent:@".."];
        }
    } else {
        finalPath = @"./";
    }
    if (ai == absoluteComps.count) {
        return @".";
    } else {
        for (; ai < absoluteComps.count; ai++) {
            finalPath = [finalPath stringByAppendingPathComponent:absoluteComps[ai]];
        }
        return finalPath;
    }
}


- (NSString*)absolutePathWithBase:(NSString*)basePath {
    basePath = [[NSURL fileURLWithPath:basePath] path];
    NSArray *relativeComps = [self pathComponents];
    NSArray *baseComps = [basePath pathComponents];
    NSUInteger bi = 0;
    for (NSString *comp in relativeComps) {
        if ([comp isEqualToString:@".."]) {
            bi++;
        } else {
            break;
        }
    }
    NSUInteger maxBaseCount = baseComps.count-bi;
    // bi = (bi==0 ? 1 : bi);
    NSString *finalPath = @"/";
    for (NSUInteger i = 0; i<maxBaseCount; i++) {
        finalPath = [finalPath stringByAppendingPathComponent:baseComps[i]];
    }
    for (NSUInteger i = bi; i < relativeComps.count; i++) {
        finalPath = [finalPath stringByAppendingPathComponent:relativeComps[i]];
    }
    return finalPath;
}
@end

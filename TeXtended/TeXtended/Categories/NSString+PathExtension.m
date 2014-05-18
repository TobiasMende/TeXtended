//
//  NSString+PathExtension.m
//  TeXtended
//
//  Created by Tobias Mende on 02.08.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "NSString+PathExtension.h"

@implementation NSString (PathExtension)

    - (NSString *)relativePathWithBase:(NSString *)basePath
    {
        basePath = [[[NSURL fileURLWithPath:basePath] path] stringByStandardizingPath];
        NSArray *absoluteComps = [self pathComponents];
        NSArray *baseComps = [basePath pathComponents];
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
        NSMutableArray *finalComponents = [NSMutableArray arrayWithObject:@""];
        if (bi < baseComps.count) {
            for (; bi < baseComps.count ; bi++) {
                [finalComponents addObject:@".."];
            }
        } else {
            [finalComponents removeAllObjects];
            [finalComponents addObject:@"."];
        }
        if (ai == absoluteComps.count) {
            return @".";
        } else {
            for (; ai < absoluteComps.count ; ai++) {
                [finalComponents addObject:absoluteComps[ai]];
            }
            return [[NSString pathWithComponents:finalComponents] stringByStandardizingPath];
        }
    }


    - (NSString *)absolutePathWithBase:(NSString *)basePath
    {
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
        NSUInteger maxBaseCount = baseComps.count - bi;
        // bi = (bi==0 ? 1 : bi);
        NSMutableArray *finalComponents = [NSMutableArray arrayWithCapacity:maxBaseCount + relativeComps.count + 1];
        [finalComponents addObject:@"/"];
        for (NSUInteger i = 0 ; i < maxBaseCount ; i++) {
            [finalComponents addObject:baseComps[i]];
        }
        for (NSUInteger i = bi ; i < relativeComps.count ; i++) {
            [finalComponents addObject:relativeComps[i]];
        }
        return [[NSString pathWithComponents:finalComponents] stringByStandardizingPath];
    }
@end

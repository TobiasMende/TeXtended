//
//  Parser.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Parser.h"
#import "PathFactory.h"

@implementation Parser

    - (void)parseDocument:(NSString *)path callbackBlock:(void (^)(NSArray *messages))completionHandler
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    }

    - (NSArray *)parseContent:(NSString *)content forDocument:(NSString *)path
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    }

    - (BOOL)infoValid:(NSString *)info
    {
        return NO;
    }

    - (NSArray *)parseOutput:(NSString *)output withBaseDir:(NSString *)base
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    }

    - (NSString *)absolutPath:(NSString *)path withBaseDir:(NSString *)base
    {
        if ([path isAbsolutePath]) {
            return [PathFactory realPathFromTemporaryStorage:path];
        }
        return [PathFactory realPathFromTemporaryStorage:[base stringByAppendingPathComponent:path]];
    }

    - (void)terminate
    {
        completionHandler = nil;
    }

@end

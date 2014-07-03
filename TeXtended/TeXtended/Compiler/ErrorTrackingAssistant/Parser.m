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
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                     userInfo:nil];
    }

    - (NSArray *)parseContent:(NSString *)content forDocument:(NSString *)path
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                     userInfo:nil];
    }

    - (BOOL)infoValid:(NSString *)info
    {
        return NO;
    }

    - (NSArray *)parseOutput:(NSString *)output withBaseDir:(NSString *)base
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                     userInfo:nil];
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

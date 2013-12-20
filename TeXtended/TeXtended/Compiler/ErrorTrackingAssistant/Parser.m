//
//  Parser.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Parser.h"
#import "PathFactory.h"
#import "MessageCollection.h"

@implementation Parser

- (void)parseDocument:(NSString *)path callbackBlock:(void (^)(MessageCollection *messages))completionHandler {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return;
}

- (MessageCollection *)parseContent:(NSString *)content forDocument:(NSString *)path {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)infoValid:(NSString *)info {
    return NO;
}

- (MessageCollection *)parseOutput:(NSString *)output withBaseDir:(NSString *)base {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (NSString *)absolutPath:(NSString *)path withBaseDir:(NSString *)base {
    if ([path isAbsolutePath]) {
        return [PathFactory realPathFromTemporaryStorage:path];
    }
    return [PathFactory realPathFromTemporaryStorage:[base stringByAppendingPathComponent:path]];
}

- (void)terminate {
    completionHandler = nil;
}

@end

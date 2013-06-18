//
//  Parser.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Parser.h"

@implementation Parser

- (NSSet *)parseDocument:(NSString *)path {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)infoValid:(NSString *)info {
    return NO;
}

- (NSSet *)parseOutput:(NSString *)output withBaseDir:(NSString *)base {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (NSString *)absolutPath:(NSString *)path withBaseDir:(NSString *)base {
    if ([path isAbsolutePath]) {
        return path;
    }
    return [base stringByAppendingPathComponent:path];
}
@end

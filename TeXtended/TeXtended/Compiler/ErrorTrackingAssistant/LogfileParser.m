//
//  LogfileParser.m
//  TeXtended
//
//  Created by Tobias Mende on 20.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "LogfileParser.h"

@implementation LogfileParser

-(MessageCollection *)parseContent:(NSString *)content forDocument:(NSString *)path {
    return [self parseOutput:content withBaseDir:[path stringByDeletingLastPathComponent]];
}

- (MessageCollection *)parseOutput:(NSString *)output withBaseDir:(NSString *)base {
    NSArray *lines = [output componentsSeparatedByString:@"\n"];
}

@end

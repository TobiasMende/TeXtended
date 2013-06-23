//
//  LogfileParser.m
//  TeXtended
//
//  Created by Tobias Mende on 20.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "LogfileParser.h"
#import "TrackingMessage.h"
#import "MessageCollection.h"

static const NSRegularExpression *ERROR_LINES_EXPRESSION;
@implementation LogfileParser

+ (void)initialize {
    if (self == [LogfileParser class]) {
        NSString *regex = @"^([.|/].*?):(.*?): (.*)(?:\\n|.)*?^l\\.(?:.*) (.*)$";
        NSError *error;
        ERROR_LINES_EXPRESSION = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionAnchorsMatchLines error:&error];
        if (error) {
            NSLog(@"Error while generating log file parser regex: %@", [error userInfo]);
        }
    }
}

-(MessageCollection *)parseContent:(NSString *)content forDocument:(NSString *)path {
    
    MessageCollection *collection = [MessageCollection new];
    NSArray *matches = [ERROR_LINES_EXPRESSION matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    
    for (NSTextCheckingResult *match in matches) {
        if (match.numberOfRanges < 5) {
            continue;
        }
        NSString *doc = [content substringWithRange:[match rangeAtIndex:1]];
        doc = [self absolutPath:doc withBaseDir:[path stringByDeletingLastPathComponent]];
        NSString *lineStr = [content substringWithRange:[match rangeAtIndex:2]];
        NSString *title = [content substringWithRange:[match rangeAtIndex:3]];
        NSString *info = [content substringWithRange:[match rangeAtIndex:4]];
        TrackingMessage *m = [TrackingMessage errorInDocument:doc inLine:[lineStr integerValue] withTitle:title andInfo:info];
        [collection addMessage:m];
        
    }
    
    return collection;
}

@end

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
#import "TMTLog.h"

static const NSRegularExpression *ERROR_LINES_EXPRESSION;
static const NSDictionary *LATEX_ERROR_EXTENSIONS;
@interface LogfileParser ()
- (NSString *) furtherInformationForError:(NSString*)title andInfo:(NSString *)info;
@end

@implementation LogfileParser

+ (void)initialize {
    if (self == [LogfileParser class]) {
        NSString *regex = @"^([.|/].*?):(.*?): (.*)(?:\\n|.)*?^l\\.(?:.*?)\\s(.*)$";
        NSError *error;
        ERROR_LINES_EXPRESSION = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionAnchorsMatchLines error:&error];
        LATEX_ERROR_EXTENSIONS = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LatexErrorExtensions" ofType:@"plist"]];
        if (error) {
            DDLogError(@"Error while generating log file parser regex: %@", [error userInfo]);
        }
    }
}

/**
 * Parse a content given as string for a document given by a path and returns
 * the extracted result as MessageCollection.
 *
 * @param content as NSString
 * @param path for the document
 *
 * @return a MessageCollection holding the result
 */
-(MessageCollection*)parseContent:(NSString *)content forDocument:(NSString *)path {
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
        NSString *furtherInfo = [self furtherInformationForError:title andInfo:info];
        TrackingMessage *m = [TrackingMessage errorInDocument:doc inLine:[lineStr integerValue] withTitle:title andInfo:info];
        m.furtherInfo = furtherInfo;
        [collection addMessage:m];
        
    }
    
    return collection;
}

/**
 * Returns extended informations for a given error and info.
 *
 * @param title of the error
 * @param info for the error
 *
 * @return more informations for the title and info
 */
- (NSString *)furtherInformationForError:(NSString *)title andInfo:(NSString *)info{
    NSString *furtherInformation;
    for (NSString* key in LATEX_ERROR_EXTENSIONS) {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:key options:0 error:&error];
        
        if (error) {
            DDLogError(@"Error in regex %@: %@", key, error.userInfo);
            continue;
        }
        NSArray *matches = [regex matchesInString:title options:0 range:NSMakeRange(0, title.length)];
        if (matches.count >0) {
            NSTextCheckingResult *r = [matches objectAtIndex:0];
            furtherInformation = [LATEX_ERROR_EXTENSIONS objectForKey:key];
            if (r.numberOfRanges >1) {
                NSRange plRange = [furtherInformation rangeOfString:@"@@placeholder@@"];
                if (plRange.location != NSNotFound) {
                    NSString *placeholder = [title substringWithRange:[r rangeAtIndex:1]];
                    furtherInformation = [furtherInformation stringByReplacingCharactersInRange:plRange withString:placeholder];
                }
            }
            NSRange infoRange = [furtherInformation rangeOfString:@"@@info@@"];
            if (infoRange.location != NSNotFound) {
                furtherInformation = [furtherInformation stringByReplacingCharactersInRange:infoRange withString:info];
            }
            break;
        }
    }
    return furtherInformation;
}

@end

//
//  OutlineExtractor.m
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "OutlineExtractor.h"
#import "CompletionManager.h"
#import "CommandCompletion.h"
#import "OutlineElement.h"
#import "DocumentModel.h"
#import "NSString+PathExtension.h"
#import <TMTHelperCollection/TMTLog.h>
#import <TMTHelperCollection/NSString+TMTExtensions.h>
#import <TMTHelperCollection/NSString+LatexExtensions.h>

LOGGING_DEFAULT_DYNAMIC

static const NSDictionary *ELEMENT_EXTRACTOR_REGEX_LOOKUP;

static const NSDictionary *TYPE_STRING_LOOKUP;

@interface OutlineExtractor ()

    - (NSRegularExpression *)masterRegex;

    - (OutlineElementType)typeForRange:(NSRange)range inContent:(NSString *)content;

    - (void)backgroundExtraction:(void *)info;

    - (NSRange)firstValidRangeInResult:(NSTextCheckingResult *)result;
@end

@implementation OutlineExtractor

    + (void)initialize
    {
        if (self == [OutlineExtractor class]) {
            LOGGING_LOAD
            ELEMENT_EXTRACTOR_REGEX_LOOKUP = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"OutlineElementTypeLookupTable" ofType:@"plist"]];
            TYPE_STRING_LOOKUP = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"OutlineElementTypeStringLookupTable" ofType:@"plist"]];
        }
    }


    - (void)extractIn:(NSString *)c forModel:(DocumentModel *)m withCallback:(void (^)(NSArray *))ch
    {
        if (self.isExtracting) {
            return;
        }
        _isExtracting = YES;
        _completionHandler = ch;
        _content = c.copy;
        _model = m;
        if (!_content || !_model) {
            if (_completionHandler) {
                _completionHandler(nil);
            }
            _isExtracting = NO;
            return;
        }
        [self performSelectorInBackground:@selector(backgroundExtraction:) withObject:nil];
    }

    - (void)backgroundExtraction:(void *)info
    {

        NSRegularExpression *regex = [self masterRegex];
        if (!masterRegex) {
            if (_completionHandler) {
                _completionHandler(nil);
            }
            _isExtracting = NO;
            return;
        }

        NSArray *results = [regex matchesInString:_content options:0 range:NSMakeRange(0, _content.length)];
        NSMutableArray *outline = [NSMutableArray arrayWithCapacity:results.count];

        for (NSTextCheckingResult *result in results) {
            OutlineElement *element = [OutlineElement new];
            NSRange totalRange = result.range;
            NSRange infoRange = [self firstValidRangeInResult:result];
            if ([_content lineIsCommentForPosition:totalRange.location]) {
                continue;
            }
            if (infoRange.location == NSNotFound) {
                DDLogError(@"%li - %@", result.numberOfRanges, NSStringFromRange(totalRange));
                continue;
            }
            element.info = [_content substringWithRange:infoRange];
            element.type = [self typeForRange:totalRange inContent:_content];
            element.document = _model;
            if (element.type == INCLUDE || element.type == INPUT) {
                NSString *currentPath = element.info;
                if ([[element.info pathExtension] isEqualToString:@""]) {
                    currentPath = [currentPath stringByAppendingPathExtension:@"tex"];
                }
                if (![currentPath isAbsolutePath]) {
                    DocumentModel *main = [_model.mainDocuments firstObject];
                    NSString *base = main.texPath.stringByDeletingLastPathComponent;
                    if (base) {
                        currentPath = [currentPath absolutePathWithBase:base];
                    }
                }
                if (currentPath && _model.project) {
                    element.subNode = [_model modelForTexPath:currentPath byCreating:YES];
                    if (!element.subNode) {
                        continue;
                    }
                }
            }
            element.line = [_content lineNumberForRange:totalRange] + 1;
            [outline addObject:element];
        }

        _model.outlineElements = outline;
        if (_completionHandler) {
            _completionHandler(outline);
        }
        _isExtracting = NO;

    }

    - (NSRange)firstValidRangeInResult:(NSTextCheckingResult *)result
    {
        for (NSUInteger index = 1 ; index < result.numberOfRanges ; index++) {
            NSRange current = [result rangeAtIndex:index];
            if (current.location != NSNotFound) {
                return current;
            }
        }
        return NSMakeRange(NSNotFound, 0);
    }

    - (OutlineElementType)typeForRange:(NSRange)range inContent:(NSString *)content
    {
        if ([[content substringWithRange:NSMakeRange(range.location, 1)] isEqualToString:@"%"]) {
            return TODO;
        } else {
            NSScanner *scanner = [NSScanner scannerWithString:content];
            scanner.scanLocation = range.location;
            NSString *prefix = nil;
            [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{["] intoString:&prefix];
            if ([prefix hasSuffix:@"*"]) {
                prefix = [prefix substringToIndex:prefix.length-1];
            }
            NSNumber *type = [TYPE_STRING_LOOKUP objectForKey:prefix];
            if (type) {
                return (OutlineElementType) type.unsignedLongValue;
            } else {
                NSSet *labels = [[CompletionManager sharedInstance] commandCompletionsByType:CommandTypeLabel];
                for (NSValue *v in labels) {
                    CommandCompletion *c = v.nonretainedObjectValue;
                    if ([c.autoCompletionWord isEqualToString:prefix]) {
                        return LABEL;
                    }
                }

                NSSet *refs = [[CompletionManager sharedInstance] commandCompletionsByType:CommandTypeRef];
                for (NSValue *v in refs) {
                    CommandCompletion *c = v.nonretainedObjectValue;
                    if ([c.autoCompletionWord isEqualToString:prefix]) {
                        return REF;
                    }
                }
            }
        }
        return 0;
    }


    - (NSRegularExpression *)masterRegex
    {
        if (!masterRegex) {
            NSMutableString *regex = [NSMutableString new];
            for (NSString *part in [ELEMENT_EXTRACTOR_REGEX_LOOKUP allValues]) {
                [regex appendFormat:@"%@|", part];
            }
            NSSet *labels = [[CompletionManager sharedInstance] commandCompletionsByType:CommandTypeLabel];
            for (NSValue *v in labels) {
                CommandCompletion *c = v.nonretainedObjectValue;
                NSString *part = [NSString stringWithFormat:@"\\%@\\{(.*)\\}", c.insertion];
                [regex appendFormat:@"%@|", part];
            }
            
            NSSet *refs = [[CompletionManager sharedInstance] commandCompletionsByType:CommandTypeRef];
            for (NSValue *v in refs) {
                CommandCompletion *c = v.nonretainedObjectValue;
                NSString *part = [NSString stringWithFormat:@"\\%@\\{(.*)\\}", c.insertion];
                [regex appendFormat:@"%@|", part];
            }
            
            [regex deleteCharactersInRange:NSMakeRange(regex.length - 1, 1)];
            NSError *error;
            masterRegex = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&error];
            if (error) {
                DDLogError(@"%@", error);
            }
        }


        return masterRegex;
    }

@end

//
//  LatexSpellChecker.m
//  TeXtended
//
//  Created by Tobias Mende on 08.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "LatexSpellChecker.h"
#import <TMTHelperCollection/TMTLog.h>
#import <TMTHelperCollection/NSString+LatexExtensions.h>

LOGGING_DEFAULT

@interface LatexSpellChecker ()

    - (NSArray *)removeLatexResultsFrom:(NSArray *)results inContext:(NSString *)content;

    - (NSString *)descriptionForResultType:(NSTextCheckingType)type;
@end

@implementation LatexSpellChecker

    - (id)init
    {
        self = [super init];
        return self;
    }

- (NSInteger)requestCheckingOfString:(NSString *)stringToCheck range:(NSRange)range types:(NSTextCheckingTypes)checkingTypes options:(NSDictionary<NSString *,id> *)options inSpellDocumentWithTag:(NSInteger)tag completionHandler:(void (^)(NSInteger, NSArray<NSTextCheckingResult *> * _Nonnull, NSOrthography * _Nonnull, NSInteger))completionHandler {
    void (^adapter)(NSInteger, NSArray *, NSOrthography *, NSInteger);
    adapter = ^(NSInteger sequenceNumber, NSArray *tmpResults, NSOrthography *orthography, NSInteger wordCount)
    {
        NSArray *results = [self removeLatexResultsFrom:tmpResults inContext:stringToCheck];
        completionHandler(sequenceNumber, results, orthography, wordCount);
    };
    
    return [super requestCheckingOfString:stringToCheck range:range types:checkingTypes options:options inSpellDocumentWithTag:tag completionHandler:adapter];
}

# pragma mark - Private Methods

    - (NSArray *)removeLatexResultsFrom:(NSArray *)results inContext:(NSString *)content
    {
        NSMutableArray *finalResults = [NSMutableArray arrayWithCapacity:results.count];
        if (!prefixesToIgnore) {
            NSString *strings = [NSString                           stringWithContentsOfFile:[[NSBundle mainBundle]
                    pathForResource:@"SpellCheckerPrefixesToIgnore" ofType:@"list"] encoding:NSUTF8StringEncoding error:NULL];

            prefixesToIgnore = [strings componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            if (!prefixesToIgnore) {
                DDLogError(@"Can't load prefixes!");
            }

        }

        for (NSTextCheckingResult *result in results) {
            NSRange range = result.range;
            if (result.resultType != NSTextCheckingTypeSpelling) {
                [finalResults addObject:result];
                continue;
            }
            if (![content numberOfBackslashesBeforePositionIsEven:range.location]) {
                continue;
            }
            NSRange prefix = [content latexCommandPrefixRangeBeforePosition:range.location];
            if (prefix.location != NSNotFound && [prefixesToIgnore containsObject:[content substringWithRange:prefix]]) {
                continue;
            }
            [finalResults addObject:result];
        }
        return finalResults;
    }

    - (NSString *)descriptionForResultType:(NSTextCheckingType)type
    {
        switch (type) {
            case NSTextCheckingTypeOrthography:
                return @"Orthography";
                break;
            case NSTextCheckingTypeGrammar:
                return @"Grammer";
                break;
            case NSTextCheckingTypeSpelling:
                return @"Spelling";
                break;

            default:
                return @"OTHER";
                break;
        }
    }

@end
